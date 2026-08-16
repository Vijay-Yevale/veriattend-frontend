import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';

import 'timetable_provider.dart';

class TimetableActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() {
    return const ActionInitial();
  }

  Future<void> createTimetableSlot({
    required String teacherId,
    required String subjectId,
    required String classId,
    required String room,
    required String weekDay,
    required String startTime,
    required String endTime,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(timetableRepositoryProvider);

      await repository.createTimetableSlot(
        teacherId: teacherId,
        subjectId: subjectId,
        classId: classId,
        room: room,
        weekDay: weekDay,
        startTime: startTime,
        endTime: endTime,
      );

      _invalidateTimetableCaches();

      state = const ActionSuccess('Timetable slot created successfully.');
    } on ValidationFailure catch (e) {
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

  Future<void> updateTimetableSlot({
    required String timetableId,
    required Map<String, dynamic> updates,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(timetableRepositoryProvider);

      await repository.updateTimetableSlot(
        timetableId: timetableId,
        updates: updates,
      );

      _invalidateTimetableCaches();

      state = const ActionSuccess('Timetable slot updated successfully.');
    } on ValidationFailure catch (e) {
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

  Future<void> deleteTimetableSlot({required String timetableId}) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(timetableRepositoryProvider);

      await repository.deleteTimetableSlot(timetableId: timetableId);

      _invalidateTimetableCaches();

      state = const ActionSuccess('Timetable slot deleted successfully.');
    } on ValidationFailure catch (e) {
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

  void _invalidateTimetableCaches() {
    ref.invalidate(classTimetableProvider);
    ref.invalidate(teacherTimetableProvider);
  }

  void reset() {
    state = const ActionInitial();
  }
}

final timetableActionProvider =
    NotifierProvider<TimetableActionNotifier, ActionState>(
      TimetableActionNotifier.new,
    );
