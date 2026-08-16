import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/attendance/domain/attendance_repository.dart';
import 'package:veriattend_app/services/device_id_service.dart';
import 'package:veriattend_app/services/location_service.dart';

import 'attendance_provider.dart';

sealed class StudentSubmitAttendanceState {
  const StudentSubmitAttendanceState();
}

class StudentSubmitInitial extends StudentSubmitAttendanceState {
  const StudentSubmitInitial();
}

class StudentSubmitLoading extends StudentSubmitAttendanceState {
  const StudentSubmitLoading();
}

class StudentSubmitSuccess extends StudentSubmitAttendanceState {
  final String message;
  final String verificationToken;
  final double distance;
  final int expiresIn;

  const StudentSubmitSuccess({
    this.message = "QR and location verified.",
    required this.verificationToken,
    required this.distance,
    required this.expiresIn,
  });
}

class StudentSubmitError extends StudentSubmitAttendanceState {
  final String message;
  final bool shouldCloseScanner;

  const StudentSubmitError({
    required this.message,
    required this.shouldCloseScanner,
  });
}

class StudentSubmitAttendanceNotifier
    extends Notifier<StudentSubmitAttendanceState> {
  late final AttendanceRepository _repository;
  late final LocationService _locationService;
  late final DeviceIdService _deviceIdService;

  @override
  StudentSubmitAttendanceState build() {
    _repository = ref.read(attendanceRepositoryProvider);
    _locationService = ref.read(locationServiceProvider);
    _deviceIdService = ref.read(deviceIdServiceProvider);

    return const StudentSubmitInitial();
  }

  Future<void> submitAttendance({required String qrToken}) async {
    try {
      state = const StudentSubmitLoading();

      final position = await _locationService.getCurrentPosition();
      final deviceId = await _deviceIdService.getDeviceId();

      final result = await _repository.submitAttendance(
        qrToken: qrToken,
        deviceId: deviceId,
        studentLat: position.latitude,
        studentLng: position.longitude,
      );

      state = StudentSubmitSuccess(
        verificationToken: result.verificationToken,
        distance: result.distance,
        expiresIn: result.expiresIn,
      );
    } on Failure catch (failure) {
      state = StudentSubmitError(
        message: failure.message,
        shouldCloseScanner: _shouldCloseScanner(failure),
      );
    } catch (_) {
      state = const StudentSubmitError(
        message: "Something went wrong. Please try again.",
        shouldCloseScanner: false,
      );
    }
  }

  bool _shouldCloseScanner(Failure failure) {
    if (failure is ConflictFailure) {
      return true;
    }

    if (failure is NotFoundFailure) {
      return true;
    }

    if (failure is UnauthorizedFailure) {
      return true;
    }

    return false;
  }

  void reset() {
    state = const StudentSubmitInitial();
  }
}

final studentSubmitAttendanceProvider =
    NotifierProvider<
      StudentSubmitAttendanceNotifier,
      StudentSubmitAttendanceState
    >(StudentSubmitAttendanceNotifier.new);
