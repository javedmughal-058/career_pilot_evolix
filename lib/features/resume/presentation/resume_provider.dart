import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/resume_models.dart';
import '../domain/repositories/resume_repository.dart';

class ResumeProvider extends ChangeNotifier {
  ResumeProvider(this._repo);
  final ResumeRepository _repo;
  final _uuid = const Uuid();
  List<ResumeDocument> resumes = [];
  ResumeDocument? current;
  bool loading = false;
  Future<void> loadAll() async {
    loading = true;
    notifyListeners();
    resumes = await _repo.getAll();
    loading = false;
    notifyListeners();
  }

  Future<ResumeDocument> create() async {
    final r = ResumeDocument.empty(_uuid.v4());
    await _repo.save(r);
    current = r;
    await loadAll();
    return r;
  }

  Future<void> open(String id) async {
    current = await _repo.getById(id);
    notifyListeners();
  }

  Future<void> save(ResumeDocument r) async {
    current = r.copyWith(updatedAt: DateTime.now(), isDirty: true);
    await _repo.save(current!);
    final i = resumes.indexWhere((e) => e.id == r.id);
    if (i >= 0) {
      resumes[i] = current!;
    } else {
      resumes.insert(0, current!);
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    resumes.removeWhere((e) => e.id == id);
    if (current?.id == id) current = null;
    notifyListeners();
  }

  Future<ResumeDocument> duplicate(ResumeDocument source) async {
    final r = ResumeDocument.fromJson({
      ...source.toJson(),
      'id': _uuid.v4(),
      'title': '${source.title} Copy',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isDirty': true,
    });
    await _repo.save(r);
    await loadAll();
    return r;
  }

  Future<void> toggleSection(String id, bool enabled) async {
    final r = current;
    if (r == null) return;
    await save(
      r.copyWith(
        sections: r.sections
            .map((e) => e.id == id ? e.copyWith(enabled: enabled) : e)
            .toList(),
      ),
    );
  }

  Future<void> reorderSections(int oldIndex, int newIndex) async {
    final r = current;
    if (r == null) return;
    final list = [...r.sections]..sort((a, b) => a.order.compareTo(b.order));
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    final out = [
      for (var i = 0; i < list.length; i++) list[i].copyWith(order: i),
    ];
    await save(r.copyWith(sections: out));
  }

  Future<void> addCustomSection(String title) async {
    final r = current;
    if (r == null) return;
    final id = 'custom_${_uuid.v4()}';
    final sections = [
      ...r.sections,
      ResumeSectionConfig(
        id: id,
        type: ResumeSectionType.custom,
        title: title,
        enabled: true,
        order: r.sections.length,
      ),
    ];
    final custom = {...r.customSections, id: <NamedDetailItem>[]};
    await save(r.copyWith(sections: sections, customSections: custom));
  }
}
