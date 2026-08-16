import 'package:veriattend_app/core/model/academic_summary_model.dart';
import 'package:veriattend_app/core/model/attendance_model.dart';

import 'subject_risk_model.dart';

class SubjectDetailModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;

  final AttendanceModel attendance;
  final AcademicSummaryModel academicMarks;
  final SubjectRiskModel risk;

  const SubjectDetailModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.attendance,
    required this.academicMarks,
    required this.risk,
  });

  factory SubjectDetailModel.fromJson(Map<String, dynamic> json) {
    return SubjectDetailModel(
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      subjectCode: json['subjectCode'] as String,

      attendance: AttendanceModel.fromJson(
        json['attendance'] as Map<String, dynamic>,
      ),

      academicMarks: AcademicSummaryModel.fromJson(
        json['academicMarks'] as Map<String, dynamic>,
      ),

      risk: SubjectRiskModel.fromJson(json['risk'] as Map<String, dynamic>),
    );
  }
}
