import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/features/attendance/domain/attendance_repository.dart';

import 'attendance_provider.dart';

class FaceVerifyAttendanceNotifier extends Notifier<ActionState> {
  late final AttendanceRepository _repository;

  @override
  ActionState build() {
    _repository = ref.read(attendanceRepositoryProvider);

    return const ActionInitial();
  }

  Future<void> verifyFaceAndMarkAttendance({
    required String verificationToken,
    required List<double> embedding,
  }) async {
    try {
      state = const ActionLoading();

      await _repository.verifyFaceAndMarkAttendance(
        verificationToken: verificationToken,
        embedding: embedding,
      );

      state = const ActionSuccess("Attendance marked.");
    } on Failure catch (failure) {
      state = ActionError(failure.message);
    } catch (_) {
      state = const ActionError("Something went wrong. Please try again.");
    }
  }

  void reset() {
    state = const ActionInitial();
  }
}

final faceVerifyAttendanceProvider =
    NotifierProvider<FaceVerifyAttendanceNotifier, ActionState>(
      FaceVerifyAttendanceNotifier.new,
    );
