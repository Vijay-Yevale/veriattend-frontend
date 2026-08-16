// lib/features/hod/presentation/providers/manage_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/hod/data/manage_remote_datasource.dart';
import 'package:veriattend_app/features/hod/data/manage_repository_impl.dart';
import 'package:veriattend_app/features/hod/domain/manage_repository.dart';
import 'package:veriattend_app/features/hod/domain/model/subject_model.dart';
import 'package:veriattend_app/features/hod/domain/model/teacher_assignment_model.dart';

final manageRemoteDataSourceProvider = Provider<ManageRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ManageRemoteDataSourceImpl(dioClient);
});

final manageRepositoryProvider = Provider<ManageRepository>((ref) {
  final remoteDataSource = ref.read(manageRemoteDataSourceProvider);
  return ManageRepositoryImpl(remoteDataSource);
});

final teachersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.read(manageRepositoryProvider);
  return repository.getTeachers();
});

final classesProvider = FutureProvider<List<ClassModel>>((ref) async {
  final repository = ref.read(manageRepositoryProvider);
  return repository.getClasses();
});

final subjectsProvider = FutureProvider<List<SubjectModel>>((ref) async {
  final repository = ref.read(manageRepositoryProvider);
  return repository.getSubjects();
});

final teacherAssignmentsProvider = FutureProvider<List<TeacherAssignmentModel>>(
  (ref) async {
    final repository = ref.read(manageRepositoryProvider);
    return repository.getTeacherAssignments();
  },
);

final pendingStudentsProvider = FutureProvider.autoDispose<List<UserModel>>((
  ref,
) async {
  final repository = ref.read(manageRepositoryProvider);
  return repository.getPendingStudents();
});

final studentsByClassProvider = FutureProvider.autoDispose
    .family<List<UserModel>, String>((ref, classId) async {
      final repository = ref.read(manageRepositoryProvider);
      return repository.getStudentsByClass(classId: classId);
    });
