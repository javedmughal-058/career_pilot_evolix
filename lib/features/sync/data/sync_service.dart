import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../resume/domain/entities/resume_models.dart';
import '../../resume/domain/repositories/resume_repository.dart';

class SyncService {
  SyncService(this._firestore, this._auth, this._local);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ResumeRepository _local;
  Future<void> sync() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final col = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('resumes');
    for (final local in await _local.getDirty()) {
      final remote = await col.doc(local.id).get();
      if (remote.exists) {
        final r = ResumeDocument.fromJson(
          Map<String, dynamic>.from(remote.data()!),
        );
        if (r.updatedAt.isAfter(local.updatedAt)) {
          await _local.save(r.copyWith(isDirty: false));
          continue;
        }
      }
      await col.doc(local.id).set({...local.toJson(), 'isDirty': false});
      await _local.markClean(local.id);
    }
    final remoteAll = await col.get();
    for (final snap in remoteAll.docs) {
      final remote = ResumeDocument.fromJson(
        Map<String, dynamic>.from(snap.data()),
      );
      final local = await _local.getById(remote.id);
      if (local == null ||
          (!local.isDirty && remote.updatedAt.isAfter(local.updatedAt))) {
        await _local.save(remote.copyWith(isDirty: false));
      }
    }
  }
}
