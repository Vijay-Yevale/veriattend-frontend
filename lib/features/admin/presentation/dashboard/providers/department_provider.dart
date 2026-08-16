import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/model/department_model.dart';
import '../../../../../core/providers/core_providers.dart';

import '../../../data/admin_remote_datasource.dart';
import '../../../data/admin_repository_impl.dart';
import '../../../domain/admin_repository.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AdminRemoteDataSourceImpl(dioClient);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final remoteDataSource = ref.read(adminRemoteDataSourceProvider);
  return AdminRepositoryImpl(remoteDataSource);
});

final departmentsProvider = FutureProvider<List<DepartmentModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getDepartments();
});
