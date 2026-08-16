import 'package:veriattend_app/features/teacher/domain/model/assessment_type_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/bulk_submit_result_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/class_roaster_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/mark_entry_model.dart';

abstract class AcademicRecordRepository {
  Future<List<ClassRosterEntryModel>> getClassRoster({
    required String classId,
    required String subjectId,
  });

  Future<BulkSubmitResultModel> bulkSubmitMarks({
    required String classId,
    required String subjectId,
    required AssessmentType type,
    required List<MarkEntryModel> records,
  });
}
