import 'package:dio/dio.dart';
import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';

abstract class TimetableRemoteDataSource {
  Future<List<TimetableSlotModel>> getClassTimetable({
    String? classId,
    bool today = false,
    String? day,
  });

  Future<List<TimetableSlotModel>> getTeacherTimetable({
    String? teacherId,
    bool today = false,
    String? day,
  });

  Future<TimetableSlotModel?> getActiveTeacherSlot();

  Future<TimetableSlotModel?> getActiveClassSlot({String? classId});

  Future<TimetableSlotModel> createTimetableSlot({
    required String teacherId,
    required String subjectId,
    required String classId,
    required String room,
    required String weekDay,
    required String startTime,
    required String endTime,
  });

  Future<TimetableSlotModel> updateTimetableSlot({
    required String timetableId,
    required Map<String, dynamic> updates,
  });

  Future<void> deleteTimetableSlot({required String timetableId});
}

class TimetableRemoteDataSourceImpl implements TimetableRemoteDataSource {
  final DioClient _dio;

  const TimetableRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }

    return null;
  }

  @override
  Future<List<TimetableSlotModel>> getClassTimetable({
    String? classId,
    bool today = false,
    String? day,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (today) {
        queryParameters['today'] = true;
      } else if (day != null) {
        queryParameters['day'] = day;
      }

      final path = classId == null
          ? ApiConstants.myClassTimetable
          : ApiConstants.timetableByClass(classId);

      final response = await _dio.get(
        path,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final timetable = response.data['data'] as List;

      return timetable
          .map(
            (json) => TimetableSlotModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch class timetable.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<TimetableSlotModel>> getTeacherTimetable({
    String? teacherId,
    bool today = false,
    String? day,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (today) {
        queryParameters['today'] = true;
      } else if (day != null) {
        queryParameters['day'] = day;
      }

      final path = teacherId == null
          ? ApiConstants.myTeacherTimetable
          : ApiConstants.timetableByTeacher(teacherId);

      final response = await _dio.get(
        path,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final timetable = response.data['data'] as List;

      return timetable
          .map(
            (json) => TimetableSlotModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch teacher timetable.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<TimetableSlotModel?> getActiveTeacherSlot() async {
    try {
      final response = await _dio.get(ApiConstants.myActiveTeacherSlot);

      final data = response.data['data'];

      if (data == null) return null;

      return TimetableSlotModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch active timetable slot.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<TimetableSlotModel?> getActiveClassSlot({String? classId}) async {
    try {
      final path = classId == null
          ? ApiConstants.myActiveClassSlot
          : ApiConstants.activeSlotByClass(classId);

      final response = await _dio.get(path);

      final data = response.data['data'];

      if (data == null) return null;

      return TimetableSlotModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch active class slot.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<TimetableSlotModel> createTimetableSlot({
    required String teacherId,
    required String subjectId,
    required String classId,
    required String room,
    required String weekDay,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.createTimetableSlot,
        body: {
          'teacherId': teacherId,
          'subjectId': subjectId,
          'classId': classId,
          'room': room,
          'weekDay': weekDay,
          'startTime': startTime,
          'endTime': endTime,
        },
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return TimetableSlotModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to create timetable slot.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<TimetableSlotModel> updateTimetableSlot({
    required String timetableId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.updateTimetableSlot(timetableId),
        body: updates,
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return TimetableSlotModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to update timetable slot.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTimetableSlot({required String timetableId}) async {
    try {
      await _dio.delete(ApiConstants.deleteTimetableSlot(timetableId));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to delete timetable slot.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
