import 'package:dio/dio.dart';

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_active_session_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_session_roster_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/attendance_verifaction_model.dart';
import 'package:veriattend_app/features/attendance/domain/model/teacher_session_history_model.dart';

import 'package:veriattend_app/features/attendance/domain/model/face_attendance_result_model.dart';

import '../domain/model/attendance_session_model.dart';

abstract class AttendanceRemoteDataSource {
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

  Future getTeacherSessions({required bool todayOnly});
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient _dio;

  const AttendanceRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        (e.type == DioExceptionType.cancel && e.error == 'hard-timeout');
  }

  @override
  Future<AttendanceSessionModel> startSession({
    required double anchorLat,
    required double anchorLng,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.startAttendanceSession,
        body: {'anchorLat': anchorLat, 'anchorLng': anchorLng},
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return AttendanceSessionModel.fromJson(json);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to start attendance session.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> endSession({required String sessionId}) async {
    try {
      await _dio.patch(ApiConstants.endAttendanceSession(sessionId));
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to end attendance session.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<SessionRosterModel> getSessionReview({
    required String sessionId,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.sessionReview(sessionId),
        queryParameters: search == null || search.trim().isEmpty
            ? null
            : {'search': search},
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return SessionRosterModel.fromJson(json);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch session review.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> markManualAttendance({
    required String sessionId,
    required List<String> studentIds,
    required String reason,
  }) async {
    try {
      await _dio.post(
        ApiConstants.manualAttendance(sessionId),
        body: {'studentIds': studentIds, 'reason': reason},
      );
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to mark manual attendance.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  // ACTIVE ATTENDANCE SESSION

  @override
  Future<AttendanceActiveSessionModel?> getActiveSession({
    required String classId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.activeSessionByClass(classId),
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return AttendanceActiveSessionModel.fromJson(json);
    } on DioException catch (e) {
      // No active lecture right now is an expected state, not a failure.
      if (e.response?.statusCode == 404) {
        return null;
      }

      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch active attendance session.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  // SUBMIT ATTENDANCE — STAGE 1 (QR + GPS only)

  @override
  Future<AttendanceVerificationModel> submitAttendance({
    required String qrToken,
    required String deviceId,
    required double studentLat,
    required double studentLng,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.submitAttendance,
        body: {
          'qrToken': qrToken,
          'deviceId': deviceId,
          'studentLat': studentLat,
          'studentLng': studentLng,
        },
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return AttendanceVerificationModel.fromJson(json);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to submit attendance.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  // VERIFY FACE + MARK ATTENDANCE — STAGE 2

  @override
  Future<FaceAttendanceResultModel> verifyFaceAndMarkAttendance({
    required String verificationToken,
    required List<double> embedding,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyFaceAttendance,
        body: {'verificationToken': verificationToken, 'embedding': embedding},
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return FaceAttendanceResultModel.fromJson(json);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Face verification failed.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future getTeacherSessions({required bool todayOnly}) async {
    try {
      final response = await _dio.get(
        ApiConstants.myTeacherSessions,
        queryParameters: {'todayOnly': todayOnly},
      );

      final json = response.data['data'] as List<dynamic>;

      return json
          .map(
            (item) => TeacherSessionHistoryModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch teacher session history.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
