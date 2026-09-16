import '../../../core/database/app_database.dart';
import '../domain/entities/resume_models.dart';
import '../domain/repositories/resume_repository.dart';

class LocalResumeRepository implements ResumeRepository {
  LocalResumeRepository(this.database);
  final AppDatabase database;
  @override
  Future<void> delete(String id) => database.deleteResume(id);
  @override
  Future<List<ResumeDocument>> getAll() => database.allResumes();
  @override
  Future<ResumeDocument?> getById(String id) => database.resume(id);
  @override
  Future<List<ResumeDocument>> getDirty() => database.dirtyResumes();
  @override
  Future<void> markClean(String id) => database.markClean(id);
  @override
  Future<void> save(ResumeDocument resume) => database.upsertResume(resume);
}
