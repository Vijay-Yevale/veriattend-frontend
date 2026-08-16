import 'package:veriattend_app/features/attendance/domain/model/attendance_active_session_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_session_roster_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_verifaction_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/teacher_session_history_model.dart';

import 'package:veriattend_app/features/attendance/domain/model/face_attendance_result_model.dart';

import 'model/attendance_session_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceSessionModel> startSession({
    required double anchorLat,
    required double anchorLng,
  });

  Future<void> endSession({required String sessionId});

  Future<SessionRosterModel> getSessionReview({
    required String sessionId,
    String? search,
  });

  Future<void> markManualAttendance({
    required String sessionId,
    required List<String> studentIds,
    required String reason,
  });

  Future<AttendanceActiveSessionModel?> getActiveSession({
    required String classId,
  });

  Future<AttendanceVerificationModel> submitAttendance({
    required String qrToken,
    required String deviceId,
    required double studentLat,
    required double studentLng,
  });

  Future<FaceAttendanceResultModel> verifyFaceAndMarkAttendance({
    required String verificationToken,
    required List<double> embedding,
  });

  Future<List<TeacherSessionHistoryModel>> getTeacherSessions({
    required bool todayOnly,
  });
}
