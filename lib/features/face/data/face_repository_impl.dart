import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/model/face_profile_model.dart';

import '../domain/face_repository.dart';
import 'face_remote_datasource.dart';

class FaceRepositoryImpl implements FaceRepository {
  final FaceRemoteDataSource _remoteDataSource;

  const FaceRepositoryImpl(this._remoteDataSource);

  Failure _mapServerException(ServerException e) {
    switch (e.statusCode) {
      case 400:
        return ValidationFailure(message: e.message);
      case 401:
        return UnauthorizedFailure(message: e.message);
      case 403:
        return UnauthorizedFailure(message: e.message);
      case 404:
        return NotFoundFailure(message: e.message);
      case 409:
        return ConflictFailure(message: e.message);
      default:
        return ServerFailure(message: e.message);
    }
  }

  @override
  Future<FaceProfileModel> enrollFace({required List<double> embedding}) async {
    try {
      return await _remoteDataSource.enrollFace(embedding: embedding);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      throw _mapServerException(e);
    }
  }

  @override
  Future<FaceProfileModel?> getFaceProfile() async {
    try {
      return await _remoteDataSource.getFaceProfile();
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      throw _mapServerException(e);
    }
  }

  @override
  Future<bool> checkFaceRegistration() async {
    try {
      return await _remoteDataSource.checkFaceRegistration();
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ParseException catch (e) {
      throw ParseFailure(message: e.message);
    } on ServerException catch (e) {
      throw _mapServerException(e);
    }
  }
}
