import 'package:veriattend_app/core/model/subject_mark_model.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/data/student_analytics_remote_datasource.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/domain/model/student_analytics_model.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/domain/student_analytics_repository.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';

class StudentAnalyticsRepositoryImpl implements StudentAnalyticsRepository {
  final StudentAnalyticsRemoteDataSource _remoteDataSource;

  const StudentAnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<StudentAnalyticsModel> getStudentAnalytics({String? studentId}) async {
    try {
      return await _remoteDataSource.getStudentAnalytics(studentId: studentId);
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
  Future<List<SubjectMarkModel>> getStudentMarks({String? studentId}) async {
    try {
      return await _remoteDataSource.getStudentMarks(studentId: studentId);
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
