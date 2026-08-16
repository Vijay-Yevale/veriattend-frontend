import 'package:veriattend_app/core/model/class_info_model.dart';
import 'package:veriattend_app/core/model/subject_info_model.dart';
import 'package:veriattend_app/core/model/teacher_model.dart';

class TeacherSessionHistoryModel {
  final String sessionId;

  final TeacherModel teacher;

  final ClassInfoModel classInfo;

  final SubjectInfoModel subject;

  final String startTime;

  final String endTime;

  final String weekDay;

  final DateTime createdAt;

  final bool isActive;

  const TeacherSessionHistoryModel({
    required this.sessionId,
    required this.teacher,
    required this.classInfo,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.weekDay,
    required this.createdAt,
    required this.isActive,
  });

  factory TeacherSessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TeacherSessionHistoryModel(
      sessionId: json['_id'] as String,

      teacher: TeacherModel.fromJson(json['teacherId'] as Map<String, dynamic>),

      classInfo: ClassInfoModel.fromJson(
        json['classId'] as Map<String, dynamic>,
      ),

      subject: SubjectInfoModel.fromJson(
        json['subjectId'] as Map<String, dynamic>,
      ),

      startTime:
          (json['timetableSlotId'] as Map<String, dynamic>)['startTime']
              as String,

      endTime:
          (json['timetableSlotId'] as Map<String, dynamic>)['endTime']
              as String,

      weekDay:
          (json['timetableSlotId'] as Map<String, dynamic>)['weekDay']
              as String,

      createdAt: DateTime.parse(json['createdAt'] as String),

      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sessionId,
      'teacherId': teacher.toJson(),
      'classId': classInfo.toJson(),
      'subjectId': subject.toJson(),
      'timetableSlotId': {
        'startTime': startTime,
        'endTime': endTime,
        'weekDay': weekDay,
      },
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
