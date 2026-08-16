import 'package:dio/dio.dart';

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/class_dashboard_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/student_subject_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/subject_dashboard_model.dart';

abstract class ClassAnalyticsRemoteDataSource {
  Future<ClassDashboardModel> getClassDashboard({required String classId});

  Future<SubjectDashboardModel> getSubjectDashboard({
    required String classId,
    required String subjectId,
  });

  Future<StudentSubjectDetailModel> getStudentSubjectDetail({
    required String studentId,
    required String subjectId,
  });
}

class ClassAnalyticsRemoteDataSourceImpl
    implements ClassAnalyticsRemoteDataSource {
  final DioClient _dio;

  const ClassAnalyticsRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  @override
  Future<ClassDashboardModel> getClassDashboard({
    required String classId,
  }) async {
    try {
      final response = await _dio.get(ApiConstants.classDashboard(classId));

      final json = response.data['data'] as Map<String, dynamic>;

      return ClassDashboardModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch class dashboard.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<SubjectDashboardModel> getSubjectDashboard({
    required String classId,
    required String subjectId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.subjectDashboard(classId, subjectId),
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return SubjectDashboardModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch subject dashboard.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<StudentSubjectDetailModel> getStudentSubjectDetail({
    required String studentId,
    required String subjectId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.studentSubjectDetail(studentId, subjectId),
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return StudentSubjectDetailModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch student subject detail.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
