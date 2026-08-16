import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';

import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/features/information/data/information_remote_datasource.dart';
import 'package:veriattend_app/features/information/domain/information_repository.dart';

class InformationRepositoryImpl implements InformationRepository {
  final InformationRemoteDatasource _remoteDataSource;

  const InformationRepositoryImpl(this._remoteDataSource);

  @override
  Future<ClassModel> getClassDetail(String classId) async {
    try {
      return await _remoteDataSource.getClassDetail(classId);
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
