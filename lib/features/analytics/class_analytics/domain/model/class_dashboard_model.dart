import 'package:veriattend_app/features/analytics/class_analytics/domain/model/available_subject_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_filter_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_student_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_summary_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/subject_dashboard_info_model.dart';

class ClassDashboardModel {
  final String classId;
  final String className;

  final DashboardSummaryModel? summary;
  final DashboardFiltersModel? filters;

  final List<DashboardStudentModel> students;

  final List<AvailableSubjectModel> availableSubjects;

  final bool? attendanceStarted;
  final SubjectDashboardInfoModel? subject;

  const ClassDashboardModel({
    required this.classId,
    required this.className,
    this.summary,
    this.filters,
    required this.students,
    this.availableSubjects = const [],
    this.attendanceStarted,
    this.subject,
  });

  factory ClassDashboardModel.fromJson(Map<String, dynamic> json) {
    return ClassDashboardModel(
      classId: json['classId']?.toString() ?? '',
      className: json['className'] as String? ?? '',

      summary: json['summary'] == null
          ? null
          : DashboardSummaryModel.fromJson(
              json['summary'] as Map<String, dynamic>,
            ),

      filters: json['filters'] == null
          ? null
          : DashboardFiltersModel.fromJson(
              json['filters'] as Map<String, dynamic>,
            ),

      students: (json['students'] as List<dynamic>? ?? [])
          .map((e) => DashboardStudentModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      availableSubjects: (json['availableSubjects'] as List<dynamic>? ?? [])
          .map((e) => AvailableSubjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      attendanceStarted: json['attendanceStarted'] as bool?,

      subject: json['subject'] == null
          ? null
          : SubjectDashboardInfoModel.fromJson(
              json['subject'] as Map<String, dynamic>,
            ),
    );
  }
}
