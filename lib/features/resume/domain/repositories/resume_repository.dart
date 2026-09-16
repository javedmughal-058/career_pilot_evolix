import '../entities/resume_models.dart';

abstract interface class ResumeRepository {
  Future<List<ResumeDocument>> getAll();
  Future<ResumeDocument?> getById(String id);
  Future<void> save(ResumeDocument resume);
  Future<void> delete(String id);
  Future<void> markClean(String id);
  Future<List<ResumeDocument>> getDirty();
}
