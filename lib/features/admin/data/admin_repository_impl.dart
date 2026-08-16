import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/model/department_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';

import '../domain/admin_repository.dart';
import 'admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  const AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DepartmentModel>> getDepartments() async {
    try {
      return await _remoteDataSource.getDepartments();
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
  Future<DepartmentModel> createDepartment({
    required String name,
    required String code,
  }) async {
    try {
      return await _remoteDataSource.createDepartment(name: name, code: code);
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
  Future<UserModel> createHod({
    required String userName,
    required String email,
    required String password,
    required String departmentId,
  }) async {
    try {
      return await _remoteDataSource.createHod(
        userName: userName,
        email: email,
        password: password,
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
