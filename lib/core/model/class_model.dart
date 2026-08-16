// lib/features/auth/domain/models/class_model.dart

import 'package:veriattend_app/core/model/teacher_model.dart';

class ClassModel {
  final String id;
  final String className;
  final String departmentId;
  final int semester;
  final String academicYear;
  final TeacherModel? classTeacher;

  const ClassModel({
    required this.id,
    required this.className,
    required this.departmentId,
    required this.semester,
    required this.academicYear,
    this.classTeacher,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    TeacherModel? teacher;

    // Backend may return either:
    // 1. String ObjectId
    // 2. Populated teacher object
    if (json['classTeacherId'] is Map<String, dynamic>) {
      teacher = TeacherModel.fromJson(
        json['classTeacherId'] as Map<String, dynamic>,
      );
    }

    return ClassModel(
      id: json['_id'] as String,
      className: json['className'] as String,
      departmentId: json['departmentId'] as String,
      semester: (json['semester'] as num).toInt(),
      academicYear: json['academicYear'] as String,
      classTeacher: teacher,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'className': className,
      'departmentId': departmentId,
      'semester': semester,
      'academicYear': academicYear,
      'classTeacherId': classTeacher?.toJson(),
    };
  }
}
