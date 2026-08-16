import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/errors/exceptions.dart';
import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';
import 'package:veriattend_app/core/network/dio_client.dart';
import 'package:veriattend_app/features/hod/domain/model/subject_model.dart';
import 'package:veriattend_app/features/hod/domain/model/teacher_assignment_model.dart';

abstract class ManageRemoteDataSource {
  Future<List<UserModel>> getTeachers();

  Future<UserModel> createTeacher({
    required String userName,
    required String email,
    required String password,
  });

  Future<List<ClassModel>> getClasses();

  Future<ClassModel> createClass({
    required String className,
    required String academicYear,
    required int semester,
    String? classTeacherId,
  });

  Future<List<SubjectModel>> getSubjects();

  Future<SubjectModel> createSubject({
    required String subjectName,
    required String subjectCode,
    required int semester,
  });

  Future<void> assignTeacher({
    required String teacherId,
    required String subjectId,
    required String classId,
  });

  Future<List<TeacherAssignmentModel>> getTeacherAssignments();

  Future<List<UserModel>> getPendingStudents();

  Future<List<UserModel>> getStudentsByClass({required String classId});

  Future<void> bulkAssignStudents({
    required String classId,
    required List<String> studentIds,
  });
}

class ManageRemoteDataSourceImpl implements ManageRemoteDataSource {
  final DioClient _dio;

  const ManageRemoteDataSourceImpl(this._dio);

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }

    return null;
  }

  @override
  Future<List<UserModel>> getTeachers() async {
    try {
      final response = await _dio.get(ApiConstants.manageTeachers);

      final teachers = response.data['data'] as List;

      return teachers
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to fetch teachers.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<UserModel> createTeacher({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.manageTeachers,
        body: {'userName': userName, 'email': email, 'password': password},
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return UserModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ??
            'Failed to create teacher account.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ClassModel> createClass({
    required String className,
    required String academicYear,
    required int semester,
    String? classTeacherId,
  }) async {
    try {
      final body = <String, dynamic>{
        'className': className,
        'academicYear': academicYear,
        'semester': semester,
      };

      if (classTeacherId != null) {
        body['classTeacherId'] = classTeacherId;
      }

      final response = await _dio.post(ApiConstants.classes, body: body);

      final json = response.data['data'] as Map<String, dynamic>;

      return ClassModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint("STATUS: ${e.response?.statusCode}");
        debugPrint("BODY: ${e.response?.data}");
        throw const NetworkException();
      }

      throw ServerException(
        message: _extractMessage(e.response?.data) ?? 'Failed to create class.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await _dio.get(ApiConstants.classes);

      final classes = response.data['data'] as List;

      return classes
          .map((json) => ClassModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint("STATUS: ${e.response?.statusCode}");
        debugPrint("BODY: ${e.response?.data}");
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to fetch classes.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<SubjectModel> createSubject({
    required String subjectName,
    required String subjectCode,
    required int semester,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.manageSubjects,
        body: {
          'subjectName': subjectName,
          'subjectCode': subjectCode,
          'semester': semester,
        },
      );

      final json = response.data['data'] as Map<String, dynamic>;

      return SubjectModel.fromJson(json);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to create subject.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final response = await _dio.get(ApiConstants.manageSubjects);

      final subjects = response.data['data'] as List;

      return subjects
          .map((json) => SubjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to fetch subjects.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> assignTeacher({
    required String teacherId,
    required String subjectId,
    required String classId,
  }) async {
    try {
      await _dio.post(
        ApiConstants.assignTeacher,
        body: {
          "teacherId": teacherId,
          "subjectId": subjectId,
          "classId": classId,
        },
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to assign teacher.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<TeacherAssignmentModel>> getTeacherAssignments() async {
    try {
      final response = await _dio.get(ApiConstants.assignTeacher);

      final data = response.data["data"] as List;

      return data
          .map(
            (e) => TeacherAssignmentModel.fromJson(e as Map<String, dynamic>),
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
            'Failed to fetch teacher assignments.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> getPendingStudents() async {
    try {
      final response = await _dio.get(ApiConstants.pendingStudents);

      final students = response.data['data'] as List;

      return students
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
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
            'Failed to fetch pending students.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> getStudentsByClass({required String classId}) async {
    try {
      final response = await _dio.get(ApiConstants.studentsByClass(classId));

      final students = response.data['data'] as List;

      return students
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
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
            'Failed to fetch class students.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> bulkAssignStudents({
    required String classId,
    required List<String> studentIds,
  }) async {
    try {
      await _dio.patch(
        ApiConstants.bulkAssignStudents,
        body: {'classId': classId, 'studentIds': studentIds},
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }

      throw ServerException(
        message:
            _extractMessage(e.response?.data) ?? 'Failed to assign students.',
        statusCode: e.response?.statusCode ?? 500,
      );
    } on FormatException {
      throw const ParseException();
    } catch (_) {
      rethrow;
    }
  }
}
