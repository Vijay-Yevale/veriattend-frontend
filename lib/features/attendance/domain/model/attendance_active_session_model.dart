import 'package:veriattend_app/core/model/subject_info_model.dart';
import 'package:veriattend_app/core/model/teacher_model.dart';

class AttendanceActiveSessionModel {
  final String sessionId;

  final TeacherModel teacher;

  final SubjectInfoModel subject;

  final String startTime;
  final String endTime;

  final bool isActive;

  const AttendanceActiveSessionModel({
    required this.sessionId,
    required this.teacher,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory AttendanceActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceActiveSessionModel(
      sessionId: json['_id'] as String,

      teacher: TeacherModel.fromJson(json['teacherId'] as Map<String, dynamic>),

      subject: SubjectInfoModel.fromJson(
        json['subjectId'] as Map<String, dynamic>,
      ),

      startTime:
          (json['timetableSlotId'] as Map<String, dynamic>)['startTime']
              as String,

      endTime:
          (json['timetableSlotId'] as Map<String, dynamic>)['endTime']
              as String,

      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sessionId,
      'teacherId': teacher.toJson(),
      'subjectId': subject.toJson(),
      'timetableSlotId': {'startTime': startTime, 'endTime': endTime},
      'isActive': isActive,
    };
  }
}
