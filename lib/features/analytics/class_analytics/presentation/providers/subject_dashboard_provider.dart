import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/subject_dashboard_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/providers/class_analytics_provider.dart';

class SubjectDashboardParams {
  final String classId;
  final String subjectId;

  const SubjectDashboardParams({
    required this.classId,
    required this.subjectId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectDashboardParams &&
          runtimeType == other.runtimeType &&
          classId == other.classId &&
          subjectId == other.subjectId;

  @override
  int get hashCode => Object.hash(classId, subjectId);
}

final subjectDashboardProvider = FutureProvider.autoDispose
    .family<SubjectDashboardModel, SubjectDashboardParams>((ref, params) async {
      ref.onDispose(() {});

      try {
        final repository = ref.read(classAnalyticsRepositoryProvider);

        final result = await repository.getSubjectDashboard(
          classId: params.classId,
          subjectId: params.subjectId,
        );

        return result;
      } catch (e) {
        rethrow;
      }
    });
