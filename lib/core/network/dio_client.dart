// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  final Dio _dio;
  final SecureStorage _secureStorage;

  final Future<void> Function()? onUnauthorized;

  DioClient(this._secureStorage, {this.onUnauthorized})
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(_authInterceptor());
  }

  // ─── Auth Interceptor ─────────────────────────────────
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getToken();

        print("========== REQUEST ==========");
        print("${options.method} ${options.path}");
        print("Token exists: ${token != null}");

        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }

        return handler.next(options);
      },

      onResponse: (response, handler) {
        print(
          'RESPONSE : ${response.statusCode} ${response.requestOptions.path}',
        );
        return handler.next(response);
      },

      onError: (DioException error, handler) async {
        print(
          'ERROR    : ${error.response?.statusCode} ${error.requestOptions.path} — ${error.type}',
        );

        if (error.response?.statusCode == 401) {
          await _secureStorage.clearAll();
          // Local state flip + navigation. We still call handler.next(error)
          // right after — the failing request's own caller should still get
          // its UnauthorizedFailure/whatever if it wants to show a message;
          // it just no longer has to be the thing that triggers logout.
          await onUnauthorized?.call();
        }

        return handler.next(error);
      },
    );
  }

  // ─── HTTP Methods ─────────────────────────────────────  (unchanged)

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: body, queryParameters: queryParameters);
  }

  Future<Response> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch(path, data: body, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: body, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }
}
