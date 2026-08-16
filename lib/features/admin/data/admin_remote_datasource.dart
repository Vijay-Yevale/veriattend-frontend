import 'package:dio/dio.dart';

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/model/department_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';
import 'package:veriattend_app/core/network/dio_client.dart';

abstract class AdminRemoteDataSource {
  Future<List<DepartmentModel>> getDepartments();

  Future<DepartmentModel> createDepartment({
    required String name,
    required String code,
  });

  Future<UserModel> createHod({
    required String userName,
    required String email,
    required String password,
    required String departmentId,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient _dio;

  const AdminRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final response = await _dio.get(ApiConstants.adminDepartments);

      final departments = response.data['data'] as List;

      return departments
          .map((json) => DepartmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to fetch departments.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<DepartmentModel> createDepartment({
    required String name,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminDepartments,
        body: {'name': name, 'code': code},
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return DepartmentModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to create department.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<UserModel> createHod({
    required String userName,
    required String email,
    required String password,
    required String departmentId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminHod,
        body: {
          'userName': userName,
          'email': email,
          'password': password,
          'departmentId': departmentId,
        },
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return UserModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to create HOD account.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
