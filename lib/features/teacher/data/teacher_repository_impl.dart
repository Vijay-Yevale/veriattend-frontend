import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/features/teacher/data/teacher_remote_datasource.dart';
import 'package:veriattend_app/features/teacher/domain/model/teacher_class_summary_model.dart';
import 'package:veriattend_app/features/teacher/domain/teacher_repository.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource _remoteDataSource;

  const TeacherRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TeacherClassSummaryModel>> getMyClasses() async {
    try {
      return await _remoteDataSource.getMyClasses();
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
