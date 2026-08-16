import 'package:veriattend_app/core/model/teacher_model.dart';

class SubjectDashboardInfoModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;

  final TeacherModel teacher;

  const SubjectDashboardInfoModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.teacher,
  });

  factory SubjectDashboardInfoModel.fromJson(Map<String, dynamic> json) {
    return SubjectDashboardInfoModel(
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      subjectCode: json['subjectCode'] as String,
      teacher: TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>),
    );
  }
}
