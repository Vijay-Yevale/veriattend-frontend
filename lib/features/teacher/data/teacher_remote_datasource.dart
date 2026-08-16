import 'package:dio/dio.dart';
import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/teacher/domain/model/teacher_class_summary_model.dart';

abstract class TeacherRemoteDataSource {
  Future<List<TeacherClassSummaryModel>> getMyClasses();
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final DioClient _dio;

  const TeacherRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  @override
  Future<List<TeacherClassSummaryModel>> getMyClasses() async {
    try {
      final response = await _dio.get(ApiConstants.myClasses);

      final classes = response.data['data'] as List;

      return classes
          .map(
            (json) =>
                TeacherClassSummaryModel.fromJson(json as Map<String, dynamic>),
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
            _extractMessage(e.response?.data) ?? 'Failed to fetch classes.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
