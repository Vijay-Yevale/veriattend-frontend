import 'package:veriattend_app/core/model/class_info_model.dart';
import 'package:veriattend_app/core/model/subject_info_model.dart';
import 'package:veriattend_app/core/model/teacher_model.dart';

class TeacherAssignmentModel {
  final String assignmentId;
  final TeacherModel teacher;
  final SubjectInfoModel subject;
  final ClassInfoModel classInfo;
  final bool isActive;

  const TeacherAssignmentModel({
    required this.assignmentId,
    required this.teacher,
    required this.subject,
    required this.classInfo,
    required this.isActive,
  });

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> json) {
    final assignmentId = json['_id'] as String?;
    if (assignmentId == null) {
      throw const FormatException('TeacherAssignmentModel: missing _id');
    }

    final teacherJson = json['teacherId'];
    if (teacherJson is! Map<String, dynamic>) {
      throw FormatException(
        'TeacherAssignmentModel($assignmentId): teacherId is missing or '
        'unpopulated (got ${teacherJson.runtimeType}). The referenced '
        'teacher may have been deleted.',
      );
    }

    final subjectJson = json['subjectId'];
    if (subjectJson is! Map<String, dynamic>) {
      throw FormatException(
        'TeacherAssignmentModel($assignmentId): subjectId is missing or '
        'unpopulated (got ${subjectJson.runtimeType}). The referenced '
        'subject may have been deleted.',
      );
    }

    final classJson = json['classId'];
    if (classJson is! Map<String, dynamic>) {
      throw FormatException(
        'TeacherAssignmentModel($assignmentId): classId is missing or '
        'unpopulated (got ${classJson.runtimeType}). The referenced '
        'class may have been deleted.',
      );
    }

    return TeacherAssignmentModel(
      assignmentId: assignmentId,
      teacher: TeacherModel.fromJson(teacherJson),
      subject: SubjectInfoModel.fromJson(subjectJson),
      classInfo: ClassInfoModel.fromJson(classJson),
      isActive:
          json['isActive'] as bool? ??
          true, // tweak default if false is safer for your domain
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': assignmentId,
      'teacherId': teacher.toJson(),
      'subjectId': subject.toJson(),
      'classId': classInfo.toJson(),
      'isActive': isActive,
    };
  }
}
