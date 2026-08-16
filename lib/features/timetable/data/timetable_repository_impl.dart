import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/features/timetable/data/timetable_remote_datasource.dart';

import '../domain/model/timetable_slot_model.dart';
import '../domain/timetable_repository.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableRemoteDataSource _remoteDataSource;

  const TimetableRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TimetableSlotModel>> getClassTimetable({
    String? classId,
    bool today = false,
    String? day,
  }) async {
    try {
      return await _remoteDataSource.getClassTimetable(
        classId: classId,
        today: today,
        day: day,
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
  Future<List<TimetableSlotModel>> getTeacherTimetable({
    String? teacherId,
    bool today = false,
    String? day,
  }) async {
    try {
      return await _remoteDataSource.getTeacherTimetable(
        teacherId: teacherId,
        today: today,
        day: day,
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
  Future<TimetableSlotModel?> getActiveTeacherSlot() async {
    try {
      return await _remoteDataSource.getActiveTeacherSlot();
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
  Future<TimetableSlotModel?> getActiveClassSlot({String? classId}) async {
    try {
      return await _remoteDataSource.getActiveClassSlot(classId: classId);
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
  Future<TimetableSlotModel> createTimetableSlot({
    required String teacherId,
    required String subjectId,
    required String classId,
    required String room,
    required String weekDay,
    required String startTime,
    required String endTime,
  }) async {
    try {
      return await _remoteDataSource.createTimetableSlot(
        teacherId: teacherId,
        subjectId: subjectId,
        classId: classId,
        room: room,
        weekDay: weekDay,
        startTime: startTime,
        endTime: endTime,
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
  Future<TimetableSlotModel> updateTimetableSlot({
    required String timetableId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      return await _remoteDataSource.updateTimetableSlot(
        timetableId: timetableId,
        updates: updates,
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
  Future<void> deleteTimetableSlot({required String timetableId}) async {
    try {
      await _remoteDataSource.deleteTimetableSlot(timetableId: timetableId);
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
