import 'package:dio/dio.dart';

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_analytics_model.dart';

abstract class DepartmentAnalyticsRemoteDataSource {
  Future<DepartmentAnalyticsModel> getDepartmentAnalytics({
    String? departmentId,
  });
}

class DepartmentAnalyticsRemoteDataSourceImpl
    implements DepartmentAnalyticsRemoteDataSource {
  final DioClient _dio;

  const DepartmentAnalyticsRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  @override
  Future<DepartmentAnalyticsModel> getDepartmentAnalytics({
    String? departmentId,
  }) async {
    try {
      final response = await _dio.get(
        departmentId == null
            ? ApiConstants.departmentAnalytics()
            : ApiConstants.departmentAnalytics(departmentId),
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return DepartmentAnalyticsModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch department analytics.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
