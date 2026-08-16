// lib/core/model/attendance_model.dart

import 'subject_wise_model.dart';

class AttendanceModel {
  final double attendancePercentage;
  final int totalClasses;
  final int totalAttended;
  final int classesMissed;
  final int classesNeededFor75;
  final List<SubjectWiseModel> subjectWise;

  const AttendanceModel({
    required this.attendancePercentage,
    required this.totalClasses,
    required this.totalAttended,
    required this.classesMissed,
    required this.classesNeededFor75,
    required this.subjectWise,
  });

  /// True if at least one lecture has been conducted.
  bool get hasData => totalClasses > 0;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toDouble() ?? 0,
      totalClasses: (json['totalClasses'] as num?)?.toInt() ?? 0,
      totalAttended: (json['totalAttended'] as num?)?.toInt() ?? 0,
      classesMissed: (json['classesMissed'] as num?)?.toInt() ?? 0,
      classesNeededFor75: (json['classesNeededFor75'] as num?)?.toInt() ?? 0,
      subjectWise: (json['subjectWise'] as List<dynamic>? ?? [])
          .map((e) => SubjectWiseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
