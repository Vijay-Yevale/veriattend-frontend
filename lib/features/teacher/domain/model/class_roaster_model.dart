class ClassRosterEntryModel {
  final String studentId;
  final String userName;
  final String prn;
  final List<num> quizMarks;
  final num? quizAverage;
  final List<num> assignmentMarks;
  final num? assignmentAverage;
  final num? internalMarks;

  const ClassRosterEntryModel({
    required this.studentId,
    required this.userName,
    required this.prn,
    required this.quizMarks,
    required this.quizAverage,
    required this.assignmentMarks,
    required this.assignmentAverage,
    required this.internalMarks,
  });

  factory ClassRosterEntryModel.fromJson(Map<String, dynamic> json) {
    return ClassRosterEntryModel(
      studentId: json['studentId'] as String,
      userName: json['userName'] as String,
      prn: json['PRN'] as String,
      quizMarks: (json['quizMarks'] as List<dynamic>? ?? const [])
          .map((m) => m as num)
          .toList(),
      quizAverage: json['quizAverage'] as num?,
      assignmentMarks: (json['assignmentMarks'] as List<dynamic>? ?? const [])
          .map((m) => m as num)
          .toList(),
      assignmentAverage: json['assignmentAverage'] as num?,
      internalMarks: json['internalMarks'] as num?,
    );
  }
}
