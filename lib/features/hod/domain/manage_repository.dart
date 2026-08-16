// lib/features/hod/domain/manage_repository.dart

import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';
import 'package:veriattend_app/features/hod/domain/model/subject_model.dart';
import 'package:veriattend_app/features/hod/domain/model/teacher_assignment_model.dart';

abstract class ManageRepository {
  Future<List<UserModel>> getTeachers();

  Future<UserModel> createTeacher({
    required String userName,
    required String email,
    required String password,
  });

  Future<List<ClassModel>> getClasses();

  Future<ClassModel> createClass({
    required String className,
    required String academicYear,
    required int semester,
    String? classTeacherId,
  });

  Future<List<SubjectModel>> getSubjects();

  Future<SubjectModel> createSubject({
    required String subjectName,
    required String subjectCode,
    required int semester,
  });

  Future<void> assignTeacher({
    required String teacherId,
    required String subjectId,
    required String classId,
  });

  Future<List<TeacherAssignmentModel>> getTeacherAssignments();

  Future<List<UserModel>> getPendingStudents();

  Future<List<UserModel>> getStudentsByClass({required String classId});

  Future<void> bulkAssignStudents({
    required String classId,
    required List<String> studentIds,
  });
}
