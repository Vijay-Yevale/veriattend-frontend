import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/auth_response_model.dart';
import '../../../core/model/user_model.dart';

class AuthRemoteDatasource {
  final DioClient _dioClient;

  AuthRemoteDatasource(this._dioClient);

  Future<AuthResponseModel> register({
    required String userName,
    required String email,
    required String password,
    required String prn,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        body: {
          'userName': userName,
          'email': email,
          'password': password,

          'PRN': prn,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return AuthResponseModel(
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
        token: data['token'] as String,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return AuthResponseModel(
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
        token: data['token'] as String,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dioClient.get(ApiConstants.me);

      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw const NetworkException();
    }

    if (e.response != null) {
      final message =
          e.response?.data['message'] as String? ?? 'Something went wrong';
      final statusCode = e.response?.statusCode ?? 500;

      throw ServerException(message: message, statusCode: statusCode);
    }

    throw const ServerException(
      message: 'Something went wrong',
      statusCode: 500,
    );
  }
}
