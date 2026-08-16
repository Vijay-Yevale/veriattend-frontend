import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/student_subject_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/providers/class_analytics_provider.dart';

class StudentSubjectDetailParams {
  final String studentId;
  final String subjectId;

  const StudentSubjectDetailParams({
    required this.studentId,
    required this.subjectId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentSubjectDetailParams &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          subjectId == other.subjectId;

  @override
  int get hashCode => Object.hash(studentId, subjectId);
}

/// Student Subject Detail

final studentSubjectDetailProvider = FutureProvider.autoDispose
    .family<StudentSubjectDetailModel, StudentSubjectDetailParams>((
      ref,
      params,
    ) async {
      ref.onDispose(() {});

      try {
        final repository = ref.read(classAnalyticsRepositoryProvider);

        final result = await repository.getStudentSubjectDetail(
          studentId: params.studentId,
          subjectId: params.subjectId,
        );

        return result;
      } catch (e) {
        rethrow;
      }
    });
