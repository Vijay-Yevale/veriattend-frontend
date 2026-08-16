// lib/core/model/risk_model.dart

class RiskModel {
  final double? performanceScore;
  final String? riskLevel;
  final double? riskScore;
  final double? passProbability;
  final List<RiskSubjectModel> weakSubjects;
  final List<RiskSubjectModel> strongSubjects;
  final DateTime? lastUpdated;

  const RiskModel({
    required this.performanceScore,
    required this.riskLevel,
    required this.riskScore,
    required this.passProbability,
    required this.weakSubjects,
    required this.strongSubjects,
    required this.lastUpdated,
  });

  /// True if ML prediction has been generated.
  bool get hasData => riskLevel != null;

  factory RiskModel.fromJson(Map<String, dynamic> json) {
    return RiskModel(
      performanceScore: (json['performanceScore'] as num?)?.toDouble(),
      riskLevel: json['riskLevel'] as String?,
      riskScore: (json['riskScore'] as num?)?.toDouble(),
      passProbability: (json['passProbability'] as num?)?.toDouble(),
      weakSubjects: (json['weakSubjects'] as List<dynamic>? ?? [])
          .map((e) => RiskSubjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      strongSubjects: (json['strongSubjects'] as List<dynamic>? ?? [])
          .map((e) => RiskSubjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
    );
  }
}

class RiskSubjectModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;

  final double attendancePercentage;
  final double? quizAverage;
  final double? assignmentAverage;
  final double? internalMarks;

  final double performanceScore;
  final String riskLevel;

  const RiskSubjectModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.attendancePercentage,
    required this.quizAverage,
    required this.assignmentAverage,
    required this.internalMarks,
    required this.performanceScore,
    required this.riskLevel,
  });

  factory RiskSubjectModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subjectId'] as Map<String, dynamic>;

    return RiskSubjectModel(
      subjectId: subject['_id'] as String,
      subjectName: subject['subjectName'] as String,
      subjectCode: subject['subjectCode'] as String,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toDouble() ?? 0,
      quizAverage: (json['quizAverage'] as num?)?.toDouble(),
      assignmentAverage: (json['assignmentAverage'] as num?)?.toDouble(),
      internalMarks: (json['internalMarks'] as num?)?.toDouble(),
      performanceScore: (json['performanceScore'] as num?)?.toDouble() ?? 0,
      riskLevel: json['riskLevel'] as String? ?? "UNKNOWN",
    );
  }
}
