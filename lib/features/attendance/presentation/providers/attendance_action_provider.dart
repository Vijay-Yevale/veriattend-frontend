import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/providers/core_providers.dart';
import 'package:veriattend_app/features/attendance/domain/attendance_repository.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_session_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_session_roster_model.dart';
import 'package:veriattend_app/services/location_service.dart';
import 'package:veriattend_app/services/socket_service.dart';

import 'attendance_provider.dart';

sealed class AttendanceState {
  const AttendanceState();
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceStarting extends AttendanceState {
  const AttendanceStarting();
}

class AttendanceLive extends AttendanceState {
  final AttendanceSessionModel session;
  final int presentCount;

  const AttendanceLive({required this.session, this.presentCount = 0});

  AttendanceLive copyWith({
    AttendanceSessionModel? session,
    int? presentCount,
  }) {
    return AttendanceLive(
      session: session ?? this.session,
      presentCount: presentCount ?? this.presentCount,
    );
  }
}

class AttendanceReview extends AttendanceState {
  final AttendanceSessionModel session;
  final SessionRosterModel roster;

  const AttendanceReview({required this.session, required this.roster});

  AttendanceReview copyWith({
    AttendanceSessionModel? session,
    SessionRosterModel? roster,
  }) {
    return AttendanceReview(
      session: session ?? this.session,
      roster: roster ?? this.roster,
    );
  }
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);
}

class AttendanceActionNotifier extends Notifier<AttendanceState> {
  late final AttendanceRepository _repository;
  late final LocationService _locationService;
  late final SocketService _socketService;

  Timer? _sessionTimer;
  bool _isEnding = false;

  @override
  AttendanceState build() {
    _repository = ref.read(attendanceRepositoryProvider);
    _locationService = ref.read(locationServiceProvider);
    _socketService = ref.read(socketServiceProvider);

    ref.onDispose(() {
      _sessionTimer?.cancel();
      _socketService.clearSessionListeners();
      _socketService.disconnect();
    });

    return const AttendanceInitial();
  }

  Future<void> startAttendance() async {
    try {
      state = const AttendanceStarting();

      final position = await _locationService.getCurrentPosition();

      final session = await _repository.startSession(
        anchorLat: position.latitude,
        anchorLng: position.longitude,
      );

      await _socketService.connect();
      await _socketService.joinSession(session.sessionId);

      _registerSocketListeners();

      state = AttendanceLive(session: session, presentCount: 0);

      _startSessionTimer(session.expiresAt);
    } catch (e) {
      state = AttendanceError(e.toString());
    }
  }

  Future<void> endAttendance() async {
    if (_isEnding) return;
    _isEnding = true;

    _sessionTimer?.cancel();

    try {
      if (state is! AttendanceLive) {
        _isEnding = false;
        return;
      }

      final current = state as AttendanceLive;

      await _repository.endSession(sessionId: current.session.sessionId);

      _socketService.leaveSession(current.session.sessionId);
      _socketService.clearSessionListeners();
      _socketService.disconnect();

      final review = await _repository.getSessionReview(
        sessionId: current.session.sessionId,
      );

      state = AttendanceReview(
        session: current.session.copyWith(isActive: false),
        roster: review,
      );

      _isEnding = false;
    } catch (e) {
      _isEnding = false;
      state = AttendanceError(e.toString());
    }
  }

  Future<void> markManualAttendance({
    required List<String> studentIds,
    required String reason,
  }) async {
    if (state is! AttendanceReview) return;

    final current = state as AttendanceReview;

    await _repository.markManualAttendance(
      sessionId: current.session.sessionId,
      studentIds: studentIds,
      reason: reason,
    );

    final updatedRoster = await _repository.getSessionReview(
      sessionId: current.session.sessionId,
    );

    state = current.copyWith(roster: updatedRoster);
  }

  void resetAttendance() {
    _sessionTimer?.cancel();
    _isEnding = false;
    state = const AttendanceInitial();
  }

  void _registerSocketListeners() {
    _socketService.onQrUpdated((data) {
      if (state is! AttendanceLive) return;

      final current = state as AttendanceLive;

      final qrExpiry = DateTime.parse(data['qrExpiry'] as String);

      final updatedSession = current.session.copyWith(
        qrToken: data['qrToken'] as String,
        qrVersion: data['qrVersion'] as int,
        qrExpiry: qrExpiry,
      );

      state = current.copyWith(session: updatedSession);
    });

    _socketService.onStudentMarked((data) {
      if (state is! AttendanceLive) return;

      final current = state as AttendanceLive;

      state = current.copyWith(presentCount: data['presentCount'] as int);
    });

    _socketService.onAttendanceUpdated((data) {
      if (state is! AttendanceLive) return;

      final current = state as AttendanceLive;

      state = current.copyWith(presentCount: data['presentCount'] as int);
    });

    _socketService.onSessionEnded((_) async {
      if (_isEnding || state is! AttendanceLive) return;

      _sessionTimer?.cancel();

      final current = state as AttendanceLive;

      _socketService.leaveSession(current.session.sessionId);
      _socketService.clearSessionListeners();
      _socketService.disconnect();

      final review = await _repository.getSessionReview(
        sessionId: current.session.sessionId,
      );

      state = AttendanceReview(
        session: current.session.copyWith(isActive: false),
        roster: review,
      );
    });
  }

  void _startSessionTimer(DateTime expiresAt) {
    _sessionTimer?.cancel();

    final duration = expiresAt.difference(DateTime.now());

    if (duration.isNegative) {
      endAttendance();
      return;
    }

    _sessionTimer = Timer(duration, () {
      endAttendance();
    });
  }
}

final attendanceActionProvider =
    NotifierProvider<AttendanceActionNotifier, AttendanceState>(
      AttendanceActionNotifier.new,
    );
