import 'package:veriattend_app/core/enums/weekday.dart';
import 'package:veriattend_app/core/model/class_info_model.dart';
import 'package:veriattend_app/core/model/subject_info_model.dart';
import 'package:veriattend_app/core/model/teacher_model.dart';

class TimetableSlotModel {
  final String timetableId;

  final TeacherModel teacher;
  final SubjectInfoModel subject;
  final ClassInfoModel classInfo;

  final String room;
  final WeekDay weekDay; // Changed
  final String startTime;
  final String endTime;

  final bool isActive;

  final bool? isCompleted;
  final bool? isCurrent;
  final bool? isUpcoming;

  const TimetableSlotModel({
    required this.timetableId,
    required this.teacher,
    required this.subject,
    required this.classInfo,
    required this.room,
    required this.weekDay,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.isCompleted,
    this.isCurrent,
    this.isUpcoming,
  });

  factory TimetableSlotModel.fromJson(Map<String, dynamic> json) {
    return TimetableSlotModel(
      timetableId: json['timetableId'] as String,

      teacher: TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>),

      subject: SubjectInfoModel.fromJson(
        json['subject'] as Map<String, dynamic>,
      ),

      classInfo: ClassInfoModel.fromJson(
        json['classInfo'] as Map<String, dynamic>,
      ),

      room: json['room'] as String,

      // Convert API String -> Enum
      weekDay: WeekDayExtension.fromApi(json['weekDay'] as String),

      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isActive: json['isActive'] as bool,

      isCompleted: json['isCompleted'] as bool?,
      isCurrent: json['isCurrent'] as bool?,
      isUpcoming: json['isUpcoming'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timetableId': timetableId,
      'teacher': teacher.toJson(),
      'subject': subject.toJson(),
      'classInfo': classInfo.toJson(),
      'room': room,

      // Convert Enum -> API String
      'weekDay': weekDay.apiValue,

      'startTime': startTime,
      'endTime': endTime,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'isCurrent': isCurrent,
      'isUpcoming': isUpcoming,
    };
  }
}
