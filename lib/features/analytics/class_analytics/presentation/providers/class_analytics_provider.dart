import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/analytics/class_analytics/data/class_analytics_remote_datasource.dart';
import 'package:veriattend_app/features/analytics/class_analytics/data/class_analytics_repository_impl.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/class_analytics_repository.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/class_dashboard_model.dart';

final classAnalyticsRemoteDataSourceProvider =
    Provider<ClassAnalyticsRemoteDataSource>((ref) {
      return ClassAnalyticsRemoteDataSourceImpl(ref.read(dioClientProvider));
    });

final classAnalyticsRepositoryProvider = Provider<ClassAnalyticsRepository>((
  ref,
) {
  return ClassAnalyticsRepositoryImpl(
    ref.read(classAnalyticsRemoteDataSourceProvider),
  );
});

// Class Dashboard

// Fetches:
// - Summary
// - Filters
// - Available Subjects

final classDashboardProvider = FutureProvider.autoDispose
    .family<ClassDashboardModel, String>((ref, classId) async {
      ref.onDispose(() {});

      try {
        final repository = ref.read(classAnalyticsRepositoryProvider);

        final result = await repository.getClassDashboard(classId: classId);

        return result;
      } catch (e) {
        rethrow;
      }
    });
