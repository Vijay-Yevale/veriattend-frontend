import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/teacher/data/academic_remote_datasource.dart';
import 'package:veriattend_app/features/teacher/data/academic_repository_impl.dart';
import 'package:veriattend_app/features/teacher/domain/model/academic_repository.dart';
import 'package:veriattend_app/features/teacher/domain/model/class_roaster_model.dart';

final academicRecordRemoteDataSourceProvider =
    Provider<AcademicRecordRemoteDataSource>((ref) {
      final dioClient = ref.read(dioClientProvider);
      return AcademicRecordRemoteDataSourceImpl(dioClient);
    });

final academicRecordRepositoryProvider = Provider<AcademicRecordRepository>((
  ref,
) {
  final remoteDataSource = ref.read(academicRecordRemoteDataSourceProvider);
  return AcademicRecordRepositoryImpl(remoteDataSource);
});

final classRosterProvider = FutureProvider.autoDispose
    .family<List<ClassRosterEntryModel>, ({String classId, String subjectId})>((
      ref,
      params,
    ) async {
      final repository = ref.read(academicRecordRepositoryProvider);
      return repository.getClassRoster(
        classId: params.classId,
        subjectId: params.subjectId,
      );
    });
