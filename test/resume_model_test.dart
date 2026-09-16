import 'package:flutter_test/flutter_test.dart';
import 'package:career_pilot/features/resume/domain/entities/resume_models.dart';
void main(){test('resume serializes and keeps dynamic sections',(){final r=ResumeDocument.empty('1').copyWith(summary:'Hello');final decoded=ResumeDocument.decode(r.encode());expect(decoded.id,'1');expect(decoded.summary,'Hello');expect(decoded.sections.length,10);});}
