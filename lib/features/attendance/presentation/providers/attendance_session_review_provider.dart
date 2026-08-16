import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/features/attendance/domain/attendance_repository.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_session_roster_model.dart';

import 'attendance_provider.dart';

sealed class SessionReviewState {
  const SessionReviewState();
}

class SessionReviewLoading extends SessionReviewState {
  const SessionReviewLoading();
}

class SessionReviewLoaded extends SessionReviewState {
  final SessionRosterModel roster;

  final bool isMarking;

  const SessionReviewLoaded({required this.roster, this.isMarking = false});

  SessionReviewLoaded copyWith({SessionRosterModel? roster, bool? isMarking}) {
    return SessionReviewLoaded(
      roster: roster ?? this.roster,
      isMarking: isMarking ?? this.isMarking,
    );
  }
}

class SessionReviewError extends SessionReviewState {
  final String message;

  final bool isNotFound;

  const SessionReviewError(this.message, {this.isNotFound = false});
}

class SessionReviewNotifier extends Notifier<SessionReviewState> {
  SessionReviewNotifier(this._sessionId);

  final String _sessionId;
  late final AttendanceRepository _repository;

  @override
  SessionReviewState build() {
    _repository = ref.read(attendanceRepositoryProvider);

    _load();

    return const SessionReviewLoading();
  }

  Future<void> _load() async {
    try {
      final roster = await _repository.getSessionReview(sessionId: _sessionId);

      state = SessionReviewLoaded(roster: roster);
    } on Failure catch (e) {
      state = SessionReviewError(e.message, isNotFound: e is NotFoundFailure);
    } catch (e) {
      state = SessionReviewError(e.toString());
    }
  }

  Future<void> refresh() async {
    state = const SessionReviewLoading();
    await _load();
  }

  Future<void> markManualAttendance({
    required List<String> studentIds,
    required String reason,
  }) async {
    final current = state;

    if (current is! SessionReviewLoaded) return;

    state = current.copyWith(isMarking: true);

    try {
      await _repository.markManualAttendance(
        sessionId: _sessionId,
        studentIds: studentIds,
        reason: reason,
      );

      final updated = await _repository.getSessionReview(sessionId: _sessionId);

      state = SessionReviewLoaded(roster: updated);
    } catch (e) {
      state = current.copyWith(isMarking: false);
      rethrow;
    }
  }
}

final sessionReviewProvider = NotifierProvider.autoDispose
    .family<SessionReviewNotifier, SessionReviewState, String>(
      SessionReviewNotifier.new,
    );
