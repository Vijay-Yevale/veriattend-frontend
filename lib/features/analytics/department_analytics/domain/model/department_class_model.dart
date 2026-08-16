import 'package:veriattend_app/core/model/teacher_model.dart';

class DepartmentClassModel {
  final String classId;
  final String className;
  final TeacherModel? classTeacher;

  const DepartmentClassModel({
    required this.classId,
    required this.className,
    this.classTeacher,
  });

  factory DepartmentClassModel.fromJson(Map<String, dynamic> json) {
    return DepartmentClassModel(
      classId: json['classId'] as String,
      className: json['className'] as String,
      classTeacher: json['classTeacher'] != null
          ? TeacherModel.fromJson(json['classTeacher'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'classTeacher': classTeacher == null
          ? null
          : {
              'teacherId': classTeacher!.teacherId,
              'userName': classTeacher!.userName,
            },
    };
  }
}
