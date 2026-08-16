import 'package:dio/dio.dart';

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/model/face_profile_model.dart';
import 'package:veriattend_app/core/network/dio_client.dart';

abstract class FaceRemoteDataSource {
  Future<FaceProfileModel> enrollFace({required List<double> embedding});

  Future<FaceProfileModel?> getFaceProfile();

  Future<bool> checkFaceRegistration();
}

class FaceRemoteDataSourceImpl implements FaceRemoteDataSource {
  final DioClient _dio;

  const FaceRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }

    return null;
  }

  @override
  Future<FaceProfileModel> enrollFace({required List<double> embedding}) async {
    try {
      final response = await _dio.post(
        ApiConstants.faceEnroll,
        body: {'embedding': embedding},
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return FaceProfileModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to register face.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<FaceProfileModel?> getFaceProfile() async {
    try {
      final response = await _dio.get(ApiConstants.faceProfile);

      final json = response.data['data'];

      if (json == null) return null;

      return FaceProfileModel.fromJson(json as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to fetch face profile.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> checkFaceRegistration() async {
    try {
      final response = await _dio.get(ApiConstants.faceStatus);

      final json = response.data['data'] as Map<String, dynamic>;

      return json['registered'] as bool;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to check face registration.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
