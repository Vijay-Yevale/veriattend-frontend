import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/features/teacher/data/academic_remote_datasource.dart';
import 'package:veriattend_app/features/teacher/domain/model/academic_repository.dart';
import 'package:veriattend_app/features/teacher/domain/model/assessment_type_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/bulk_submit_result_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/class_roaster_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/mark_entry_model.dart';

class AcademicRecordRepositoryImpl implements AcademicRecordRepository {
  final AcademicRecordRemoteDataSource _remoteDataSource;

  const AcademicRecordRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ClassRosterEntryModel>> getClassRoster({
    required String classId,
    required String subjectId,
  }) async {
    try {
      return await _remoteDataSource.getClassRoster(
        classId: classId,
        subjectId: subjectId,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);
        case 401:
          throw UnauthorizedFailure(message: e.message);
        case 403:
          throw UnauthorizedFailure(message: e.message);
        case 404:
          throw NotFoundFailure(message: e.message);
        case 409:
          throw ConflictFailure(message: e.message);
        default:
          throw ServerFailure(message: e.message);
      }
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
      return await _remoteDataSource.bulkSubmitMarks(
        classId: classId,
        subjectId: subjectId,
        type: type,
        records: records,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      switch (e.statusCode) {
        case 400:
          throw ValidationFailure(message: e.message);
        case 401:
          throw UnauthorizedFailure(message: e.message);
        case 403:
          throw UnauthorizedFailure(message: e.message);
        case 404:
          throw NotFoundFailure(message: e.message);
        case 409:
          throw ConflictFailure(message: e.message);
        default:
          throw ServerFailure(message: e.message);
      }
    }
  }
}
