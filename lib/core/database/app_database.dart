import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/resume/domain/entities/resume_models.dart';
import '../../features/settings/domain/app_settings.dart';

class AppDatabase {
  Database? _db;
  Future<Database> get db async => _db ??= await _open();
  Future<Database> _open() async {
    final root = await getDatabasesPath();
    return openDatabase(
      join(root, 'career_pilot.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE resumes(id TEXT PRIMARY KEY, payload TEXT NOT NULL, updated_at INTEGER NOT NULL, dirty INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE entitlements(product_id TEXT PRIMARY KEY, granted_at INTEGER NOT NULL)',
        );
      },
    );
  }

  Future<List<ResumeDocument>> allResumes() async {
    final rows = await (await db).query('resumes', orderBy: 'updated_at DESC');
    return rows
        .map((r) => ResumeDocument.decode(r['payload'] as String))
        .toList();
  }

  Future<ResumeDocument?> resume(String id) async {
    final rows = await (await db).query(
      'resumes',
      where: 'id=?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : ResumeDocument.decode(rows.first['payload'] as String);
  }

  Future<void> upsertResume(ResumeDocument value) async {
    await (await db).insert('resumes', {
      'id': value.id,
      'payload': value.encode(),
      'updated_at': value.updatedAt.millisecondsSinceEpoch,
      'dirty': value.isDirty ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteResume(String id) async {
    await (await db).delete('resumes', where: 'id=?', whereArgs: [id]);
  }

  Future<List<ResumeDocument>> dirtyResumes() async {
    final rows = await (await db).query('resumes', where: 'dirty=1');
    return rows
        .map((r) => ResumeDocument.decode(r['payload'] as String))
        .toList();
  }

  Future<void> markClean(String id) async {
    final current = await resume(id);
    if (current != null) await upsertResume(current.copyWith(isDirty: false));
  }

  Future<AppSettings> readSettings() async {
    final rows = await (await db).query(
      'settings',
      where: 'key=?',
      whereArgs: ['app'],
      limit: 1,
    );
    return rows.isEmpty
        ? const AppSettings()
        : AppSettings.fromJson(jsonDecode(rows.first['value'] as String));
  }

  Future<void> saveSettings(AppSettings value) async {
    await (await db).insert('settings', {
      'key': 'app',
      'value': jsonEncode(value.toJson()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Set<String>> entitlements() async =>
      (await (await db).query('entitlements'))
          .map((r) => r['product_id'] as String)
          .toSet();
  Future<void> grant(String productId) async =>
      (await db).insert('entitlements', {
        'product_id': productId,
        'granted_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
}
