// lib/features/analytics/department_analytics/presentation/providers/department_analytics_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/providers/core_providers.dart';

import 'package:veriattend_app/features/analytics/department_analytics/data/department_analytics_remote_datasource.dart';
import 'package:veriattend_app/features/analytics/department_analytics/data/department_analytics_repository_impl.dart';
import 'package:veriattend_app/features/analytics/department_analytics/domain/department_analytic_repository.dart';

import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_analytics_model.dart';

final departmentAnalyticsRemoteDataSourceProvider =
    Provider<DepartmentAnalyticsRemoteDataSource>((ref) {
      return DepartmentAnalyticsRemoteDataSourceImpl(
        ref.read(dioClientProvider),
      );
    });

final departmentAnalyticsRepositoryProvider =
    Provider<DepartmentAnalyticsRepository>((ref) {
      return DepartmentAnalyticsRepositoryImpl(
        ref.read(departmentAnalyticsRemoteDataSourceProvider),
      );
    });

final departmentAnalyticsProvider = FutureProvider.autoDispose
    .family<DepartmentAnalyticsModel, String?>((ref, departmentId) async {
      ref.onDispose(() {});

      try {
        final repository = ref.read(departmentAnalyticsRepositoryProvider);

        final result = await repository.getDepartmentAnalytics(
          departmentId: departmentId,
        );

        return result;
      } catch (e) {
        rethrow;
      }
    });
