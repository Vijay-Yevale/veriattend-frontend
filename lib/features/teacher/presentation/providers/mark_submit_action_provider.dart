import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/features/teacher/domain/model/assessment_type_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/bulk_submit_result_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/mark_entry_model.dart';
import 'package:veriattend_app/features/teacher/presentation/providers/academic_record.dart';

class MarksSubmitActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() {
    return const ActionInitial();
  }

  Future<void> submitMarks({
    required String classId,
    required String subjectId,
    required AssessmentType type,
    required List<MarkEntryModel> records,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(academicRecordRepositoryProvider);

      final BulkSubmitResultModel result = await repository.bulkSubmitMarks(
        classId: classId,
        subjectId: subjectId,
        type: type,
        records: records,
      );

      ref.invalidate(classRosterProvider);

      if (result.failed.isEmpty) {
        state = ActionSuccess(
          'Marks saved for ${result.updated.length} student(s).',
        );
      } else {
        final reasons = result.failed.map((f) => f.reason).toSet().join(', ');
        state = ActionError(
          '${result.updated.length} saved, ${result.failed.length} could '
          'not be saved: $reasons',
        );
      }
    } on ValidationFailure catch (e) {
      state = ActionError(e.message);
    } on UnauthorizedFailure catch (e) {
      state = ActionError(e.message);
    } on ConflictFailure catch (e) {
      state = ActionError(e.message);
    } on NotFoundFailure catch (e) {
      state = ActionError(e.message);
    } on NetworkFailure catch (e) {
      state = ActionError(e.message);
    } on ServerFailure catch (e) {
      state = ActionError(e.message);
    } catch (_) {
      state = const ActionError('Something went wrong.');
    }
  }

  void reset() {
    state = const ActionInitial();
  }
}

final marksSubmitActionProvider =
    NotifierProvider<MarksSubmitActionNotifier, ActionState>(
      MarksSubmitActionNotifier.new,
    );
