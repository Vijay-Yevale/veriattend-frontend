import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/features/analytics/class_analytics/data/class_analytics_remote_datasource.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/class_analytics_repository.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/class_dashboard_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/student_subject_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/subject_dashboard_model.dart';

class ClassAnalyticsRepositoryImpl implements ClassAnalyticsRepository {
  final ClassAnalyticsRemoteDataSource _remoteDataSource;

  const ClassAnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<ClassDashboardModel> getClassDashboard({
    required String classId,
  }) async {
    try {
      return await _remoteDataSource.getClassDashboard(classId: classId);
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
  Future<SubjectDashboardModel> getSubjectDashboard({
    required String classId,
    required String subjectId,
  }) async {
    try {
      return await _remoteDataSource.getSubjectDashboard(
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
  Future<StudentSubjectDetailModel> getStudentSubjectDetail({
    required String studentId,
    required String subjectId,
  }) async {
    try {
      return await _remoteDataSource.getStudentSubjectDetail(
        studentId: studentId,
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
