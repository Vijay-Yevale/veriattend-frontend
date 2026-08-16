// lib/features/auth/domain/models/user_model.dart

import 'department_model.dart';
import 'class_model.dart';

class UserModel {
  final String id;
  final String userName;
  final String email;
  final String role;
  final DepartmentModel? department;

  // JSON key: "PRN"
  final String? prn;

  final ClassModel? classInfo;

  // Optional
  final String? createdAt;
  final String? updatedAt;

  const UserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    this.department,
    this.prn,
    this.classInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,

      department: json['departmentId'] != null
          ? DepartmentModel.fromJson(
              json['departmentId'] as Map<String, dynamic>,
            )
          : null,

      prn: json['PRN'] as String?,

      classInfo: json['classId'] != null
          ? ClassModel.fromJson(json['classId'] as Map<String, dynamic>)
          : null,

      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userName': userName,
      'email': email,
      'role': role,
      'departmentId': department?.toJson(),
      'PRN': prn,
      'classId': classInfo?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
