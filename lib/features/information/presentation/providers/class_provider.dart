import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/features/information/data/information_remote_datasource.dart';
import 'package:veriattend_app/features/information/data/information_repository_impl.dart';
import 'package:veriattend_app/features/information/domain/information_repository.dart';

final classRemoteDataSourceProvider = Provider<InformationRemoteDatasource>((
  ref,
) {
  return InformationRemoteDataSourceImpl(ref.read(dioClientProvider));
});

final classRepositoryProvider = Provider<InformationRepository>((ref) {
  return InformationRepositoryImpl(ref.read(classRemoteDataSourceProvider));
});

final classDetailProvider = FutureProvider.autoDispose
    .family<ClassModel, String>((ref, classId) async {
      final repository = ref.read(classRepositoryProvider);
      return repository.getClassDetail(classId);
    });
