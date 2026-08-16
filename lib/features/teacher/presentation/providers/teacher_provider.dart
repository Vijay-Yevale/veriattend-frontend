import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/teacher/data/teacher_remote_datasource.dart';
import 'package:veriattend_app/features/teacher/data/teacher_repository_impl.dart';
import 'package:veriattend_app/features/teacher/domain/model/teacher_class_summary_model.dart';
import 'package:veriattend_app/features/teacher/domain/teacher_repository.dart';

final teacherClassesRemoteDataSourceProvider =
    Provider<TeacherRemoteDataSource>((ref) {
      final dioClient = ref.read(dioClientProvider);
      return TeacherRemoteDataSourceImpl(dioClient);
    });

final teacherClassesRepositoryProvider = Provider<TeacherRepository>((ref) {
  final remoteDataSource = ref.read(teacherClassesRemoteDataSourceProvider);
  return TeacherRepositoryImpl(remoteDataSource);
});

final myClassesProvider =
    FutureProvider.autoDispose<List<TeacherClassSummaryModel>>((ref) async {
      final repository = ref.read(teacherClassesRepositoryProvider);
      return repository.getMyClasses();
    });
