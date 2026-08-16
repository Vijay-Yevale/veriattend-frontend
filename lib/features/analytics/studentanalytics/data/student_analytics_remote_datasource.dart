import 'package:dio/dio.dart';
import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/model/subject_mark_model.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/domain/model/student_analytics_model.dart';

abstract class StudentAnalyticsRemoteDataSource {
  Future<StudentAnalyticsModel> getStudentAnalytics({String? studentId});

  Future<List<SubjectMarkModel>> getStudentMarks({String? studentId});
}

class StudentAnalyticsRemoteDataSourceImpl
    implements StudentAnalyticsRemoteDataSource {
  final DioClient _dio;

  const StudentAnalyticsRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  @override
  Future<StudentAnalyticsModel> getStudentAnalytics({String? studentId}) async {
    try {
      final response = await _dio.get(
        studentId == null
            ? ApiConstants.studentDashboard
            : ApiConstants.studentDashboardById(studentId),
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return StudentAnalyticsModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch student analytics.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SubjectMarkModel>> getStudentMarks({String? studentId}) async {
    try {
      final response = await _dio.get(
        studentId == null
            ? ApiConstants.studentMarks
            : ApiConstants.studentMarksById(studentId),
      );

      final data = response.data['data'] as List<dynamic>;

      return data
          .map((e) => SubjectMarkModel.fromJson(e as Map<String, dynamic>))
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
            'Failed to fetch student marks.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (e) {
      rethrow;
    }
  }
}
