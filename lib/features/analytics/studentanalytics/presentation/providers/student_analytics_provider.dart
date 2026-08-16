import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/model/subject_mark_model.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/data/student_analytics_remote_datasource.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/data/student_analytics_repository_impl.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/domain/model/student_analytics_model.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/domain/student_analytics_repository.dart';

final studentAnalyticsRemoteDataSourceProvider =
    Provider<StudentAnalyticsRemoteDataSource>((ref) {
      return StudentAnalyticsRemoteDataSourceImpl(ref.read(dioClientProvider));
    });

final studentAnalyticsRepositoryProvider = Provider<StudentAnalyticsRepository>(
  (ref) {
    return StudentAnalyticsRepositoryImpl(
      ref.read(studentAnalyticsRemoteDataSourceProvider),
    );
  },
);

final studentAnalyticsProvider = FutureProvider.autoDispose
    .family<StudentAnalyticsModel, String?>((ref, studentId) async {
      final repository = ref.read(studentAnalyticsRepositoryProvider);

      return repository.getStudentAnalytics(studentId: studentId);
    });

final studentMarksProvider = FutureProvider.autoDispose
    .family<List<SubjectMarkModel>, String?>((ref, studentId) async {
      final repository = ref.read(studentAnalyticsRepositoryProvider);

      return repository.getStudentMarks(studentId: studentId);
    });
