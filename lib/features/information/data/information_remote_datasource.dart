import 'package:dio/dio.dart';

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/core/model/class_model.dart';

abstract class InformationRemoteDatasource {
  Future<ClassModel> getClassDetail(String classId);
}

class InformationRemoteDataSourceImpl implements InformationRemoteDatasource {
  final DioClient _dio;

  const InformationRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  @override
  Future<ClassModel> getClassDetail(String classId) async {
    try {
      final response = await _dio.get(ApiConstants.classDetail(classId));

      final json = response.data['data'] as Map<String, dynamic>;

      return ClassModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch class details.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
