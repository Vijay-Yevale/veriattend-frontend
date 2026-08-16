import 'package:veriattend_app/core/model/subject_info_model.dart';

class TeacherClassSummaryModel {
  final String classId;
  final String className;
  final String departmentId;
  final String academicYear;
  final int semester;
  final bool isClassTeacher;
  final List<SubjectInfoModel> subjects;

  const TeacherClassSummaryModel({
    required this.classId,
    required this.className,
    required this.departmentId,
    required this.academicYear,
    required this.semester,
    required this.isClassTeacher,
    required this.subjects,
  });

  factory TeacherClassSummaryModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassSummaryModel(
      classId: json['classId'] as String,
      className: json['className'] as String,
      departmentId: json['departmentId'] as String,
      academicYear: json['academicYear'] as String,
      semester: (json['semester'] as num).toInt(),
      isClassTeacher: json['isClassTeacher'] as bool? ?? false,
      subjects: (json['subjects'] as List<dynamic>? ?? const [])
          .map(
            (subject) =>
                SubjectInfoModel.fromJson(subject as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'departmentId': departmentId,
      'academicYear': academicYear,
      'semester': semester,
      'isClassTeacher': isClassTeacher,
      'subjects': subjects.map((s) => s.toJson()).toList(),
    };
  }
}
