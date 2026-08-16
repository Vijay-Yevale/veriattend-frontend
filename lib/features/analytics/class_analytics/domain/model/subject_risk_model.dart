class SubjectRiskModel {
  final double performanceScore;
  final String riskLevel;

  const SubjectRiskModel({
    required this.performanceScore,
    required this.riskLevel,
  });

  factory SubjectRiskModel.fromJson(Map<String, dynamic> json) {
    return SubjectRiskModel(
      performanceScore: (json['performanceScore'] as num?)?.toDouble() ?? 0,

      riskLevel: json['riskLevel'] as String? ?? 'UNKNOWN',
    );
  }
}
