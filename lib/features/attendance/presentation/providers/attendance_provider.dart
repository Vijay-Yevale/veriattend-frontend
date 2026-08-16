import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/providers/core_providers.dart';

import '../../data/attendance_remote_datasource.dart';
import '../../data/attendance_repository_impl.dart';
import '../../domain/attendance_repository.dart';

final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>(
  (ref) {
    final dioClient = ref.read(dioClientProvider);

    return AttendanceRemoteDataSourceImpl(dioClient);
  },
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final remoteDataSource = ref.read(attendanceRemoteDataSourceProvider);

  return AttendanceRepositoryImpl(remoteDataSource);
});
