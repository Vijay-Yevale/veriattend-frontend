// lib/core/model/subject_wise_model.dart

class SubjectWiseModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final int totalClasses;
  final int totalAttended;
  final int classesMissed;
  final double attendancePercentage;
  final int classesNeededFor75;

  const SubjectWiseModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.totalClasses,
    required this.totalAttended,
    required this.classesMissed,
    required this.attendancePercentage,
    required this.classesNeededFor75,
  });

  factory SubjectWiseModel.fromJson(Map<String, dynamic> json) {
    return SubjectWiseModel(
      subjectId: json['subjectId']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      subjectCode: json['subjectCode']?.toString() ?? '',
      totalClasses: (json['totalClasses'] as num?)?.toInt() ?? 0,
      totalAttended: (json['totalAttended'] as num?)?.toInt() ?? 0,
      classesMissed: (json['classesMissed'] as num?)?.toInt() ?? 0,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toDouble() ?? 0,
      classesNeededFor75: (json['classesNeededFor75'] as num?)?.toInt() ?? 0,
    );
  }
}
