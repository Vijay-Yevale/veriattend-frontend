import 'package:veriattend_app/features/analytics/class_analytics/domain/model/class_dashboard_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/student_subject_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/subject_dashboard_model.dart';

abstract class ClassAnalyticsRepository {
  Future<ClassDashboardModel> getClassDashboard({required String classId});

  Future<SubjectDashboardModel> getSubjectDashboard({
    required String classId,
    required String subjectId,
  });

  Future<StudentSubjectDetailModel> getStudentSubjectDetail({
    required String studentId,
    required String subjectId,
  });
}
