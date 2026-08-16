import 'package:veriattend_app/core/model/academic_summary_model.dart';
import 'package:veriattend_app/core/model/attendance_model.dart';
import 'package:veriattend_app/core/model/risk_model.dart';

class StudentAnalyticsModel {
  final AttendanceModel attendance;
  final AcademicSummaryModel? academicMarks;
  final RiskModel risk;

  const StudentAnalyticsModel({
    required this.attendance,
    required this.academicMarks,
    required this.risk,
  });

  factory StudentAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return StudentAnalyticsModel(
      attendance: AttendanceModel.fromJson(
        json['attendance'] as Map<String, dynamic>,
      ),

      academicMarks: json['academicMarks'] == null
          ? null
          : AcademicSummaryModel.fromJson(
              json['academicMarks'] as Map<String, dynamic>,
            ),

      risk: RiskModel.fromJson(json['risk'] as Map<String, dynamic>),
    );
  }
}
