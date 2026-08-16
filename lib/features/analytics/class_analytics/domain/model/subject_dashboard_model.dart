import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_filter_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_student_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_summary_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/subject_dashboard_info_model.dart';

class SubjectDashboardModel {
  final String classId;
  final String className;

  final bool attendanceStarted;

  final SubjectDashboardInfoModel subject;

  final DashboardSummaryModel? summary;
  final List<DashboardStudentModel> students;
  final DashboardFiltersModel? filters;

  const SubjectDashboardModel({
    required this.classId,
    required this.className,
    required this.attendanceStarted,
    required this.subject,
    required this.summary,
    required this.students,
    required this.filters,
  });

  factory SubjectDashboardModel.fromJson(Map<String, dynamic> json) {
    return SubjectDashboardModel(
      classId: json['classId'] as String,
      className: json['className'] as String,

      attendanceStarted: json['attendanceStarted'] as bool,

      subject: SubjectDashboardInfoModel.fromJson(
        json['subject'] as Map<String, dynamic>,
      ),

      summary: json['summary'] == null
          ? null
          : DashboardSummaryModel.fromJson(
              json['summary'] as Map<String, dynamic>,
            ),

      students: (json['students'] as List<dynamic>? ?? [])
          .map((e) => DashboardStudentModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      filters: json['filters'] == null
          ? null
          : DashboardFiltersModel.fromJson(
              json['filters'] as Map<String, dynamic>,
            ),
    );
  }
}
