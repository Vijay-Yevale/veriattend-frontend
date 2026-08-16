// lib/core/model/subject_mark_model.dart

class SubjectMarkModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;

  final List<double> quizMarks;
  final double? quizAverage;

  final List<double> assignmentMarks;
  final double? assignmentAverage;

  final double? internalMarks;

  const SubjectMarkModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.quizMarks,
    required this.quizAverage,
    required this.assignmentMarks,
    required this.assignmentAverage,
    required this.internalMarks,
  });

  /// True if this subject has any academic record.
  bool get hasData =>
      quizMarks.isNotEmpty ||
      assignmentMarks.isNotEmpty ||
      internalMarks != null;

  factory SubjectMarkModel.fromJson(Map<String, dynamic> json) {
    return SubjectMarkModel(
      subjectId: json['subjectId']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      subjectCode: json['subjectCode']?.toString() ?? '',

      quizMarks: (json['quizMarks'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),

      quizAverage: (json['quizAverage'] as num?)?.toDouble(),

      assignmentMarks: (json['assignmentMarks'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),

      assignmentAverage: (json['assignmentAverage'] as num?)?.toDouble(),

      internalMarks: (json['internalMarks'] as num?)?.toDouble(),
    );
  }
}
