import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/features/analytics/department_analytics/data/department_analytics_remote_datasource.dart';
import 'package:veriattend_app/features/analytics/department_analytics/domain/department_analytic_repository.dart';
import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_analytics_model.dart';

class DepartmentAnalyticsRepositoryImpl
    implements DepartmentAnalyticsRepository {
  final DepartmentAnalyticsRemoteDataSource _remoteDataSource;

  const DepartmentAnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<DepartmentAnalyticsModel> getDepartmentAnalytics({
    String? departmentId,
  }) async {
    try {
      return await _remoteDataSource.getDepartmentAnalytics(
        departmentId: departmentId,
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
