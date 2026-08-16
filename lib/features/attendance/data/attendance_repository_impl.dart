import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/features/attendance/data/attendance_remote_datasource.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_active_session_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_session_roster_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_verifaction_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/teacher_session_history_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/face_attendance_result_model.dart';

import '../domain/attendance_repository.dart';
import '../domain/model/attendance_session_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  const AttendanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<AttendanceSessionModel> startSession({
    required double anchorLat,
    required double anchorLng,
  }) async {
    try {
      return await _remoteDataSource.startSession(
        anchorLat: anchorLat,
        anchorLng: anchorLng,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 404:
          throw NotFoundFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }

  @override
  Future<void> endSession({required String sessionId}) async {
    try {
      await _remoteDataSource.endSession(sessionId: sessionId);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 404:
          throw NotFoundFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }

  @override
  Future<SessionRosterModel> getSessionReview({
    required String sessionId,
    String? search,
  }) async {
    try {
      return await _remoteDataSource.getSessionReview(
        sessionId: sessionId,
        search: search,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 404:
          throw NotFoundFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }

  @override
  Future<void> markManualAttendance({
    required String sessionId,
    required List<String> studentIds,
    required String reason,
  }) async {
    try {
      await _remoteDataSource.markManualAttendance(
        sessionId: sessionId,
        studentIds: studentIds,
        reason: reason,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 404:
          throw NotFoundFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }

  @override
  Future<AttendanceActiveSessionModel?> getActiveSession({
    required String classId,
  }) async {
    try {
      return await _remoteDataSource.getActiveSession(classId: classId);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }

  @override
  Future<AttendanceVerificationModel> submitAttendance({
    required String qrToken,
    required String deviceId,
    required double studentLat,
    required double studentLng,
  }) async {
    try {
      return await _remoteDataSource.submitAttendance(
        qrToken: qrToken,
        deviceId: deviceId,
        studentLat: studentLat,
        studentLng: studentLng,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 404:
          throw NotFoundFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }

  @override
  Future<FaceAttendanceResultModel> verifyFaceAndMarkAttendance({
    required String verificationToken,
    required List<double> embedding,
  }) async {
    try {
      return await _remoteDataSource.verifyFaceAndMarkAttendance(
        verificationToken: verificationToken,
        embedding: embedding,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 403:
          throw ForbiddenFailure(message: e.message);

        case 404:
          throw NotFoundFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }

  @override
  Future<List<TeacherSessionHistoryModel>> getTeacherSessions({
    required bool todayOnly,
  }) async {
    try {
      return await _remoteDataSource.getTeacherSessions(todayOnly: todayOnly);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);

        case 401:
          throw UnauthorizedFailure(message: e.message);

        case 404:
          throw NotFoundFailure(message: e.message);

        case 409:
          throw ConflictFailure(message: e.message);

        default:
          throw ServerFailure(message: e.message);
      }
    }
  }
}
