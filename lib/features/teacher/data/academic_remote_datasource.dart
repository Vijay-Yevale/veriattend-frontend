import 'package:dio/dio.dart';
import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/teacher/domain/model/assessment_type_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/bulk_submit_result_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/class_roaster_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/mark_entry_model.dart';

abstract class AcademicRecordRemoteDataSource {
  Future<List<ClassRosterEntryModel>> getClassRoster({
    required String classId,
    required String subjectId,
  });

  Future<BulkSubmitResultModel> bulkSubmitMarks({
    required String classId,
    required String subjectId,
    required AssessmentType type,
    required List<MarkEntryModel> records,
  });
}

class AcademicRecordRemoteDataSourceImpl
    implements AcademicRecordRemoteDataSource {
  final DioClient _dio;

  const AcademicRecordRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  @override
  Future<List<ClassRosterEntryModel>> getClassRoster({
    required String classId,
    required String subjectId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.classRoster(classId, subjectId),
      );

      final roster = response.data['data'] as List;

      return roster
          .map(
            (json) =>
                ClassRosterEntryModel.fromJson(json as Map<String, dynamic>),
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
            'Failed to fetch class roster.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<BulkSubmitResultModel> bulkSubmitMarks({
    required String classId,
    required String subjectId,
    required AssessmentType type,
    required List<MarkEntryModel> records,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.bulkSubmitMarks,
        body: {
          'classId': classId,
          'subjectId': subjectId,
          'type': type.value,
          'records': records.map((r) => r.toJson()).toList(),
        },
      );

      return BulkSubmitResultModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message: _extractMessage(e.response?.data) ?? 'Failed to submit marks.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
