class AcademicSummaryModel {
  final List<double> quizMarks;
  final double? quizAverage;
  final List<double> assignmentMarks;
  final double? assignmentAverage;
  final double? internalMarks;

  const AcademicSummaryModel({
    required this.quizMarks,
    required this.quizAverage,
    required this.assignmentMarks,
    required this.assignmentAverage,
    required this.internalMarks,
  });

  factory AcademicSummaryModel.fromJson(Map<String, dynamic> json) {
    return AcademicSummaryModel(
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

  bool get hasData =>
      quizMarks.isNotEmpty ||
      assignmentMarks.isNotEmpty ||
      internalMarks != null;
}
