import 'package:veriattend_app/core/model/subject_mark_model.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/domain/model/student_analytics_model.dart';

abstract class StudentAnalyticsRepository {
  Future<StudentAnalyticsModel> getStudentAnalytics({String? studentId});

  Future<List<SubjectMarkModel>> getStudentMarks({String? studentId});
}
