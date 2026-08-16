class DashboardSummaryModel {
  final int totalStudents;

  final double averageAttendance;
  final double averagePerformance;

  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;

  final int defaultersCount;

  const DashboardSummaryModel({
    required this.totalStudents,
    required this.averageAttendance,
    required this.averagePerformance,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    required this.defaultersCount,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,

      averageAttendance: (json['averageAttendance'] as num?)?.toDouble() ?? 0,

      averagePerformance: (json['averagePerformance'] as num?)?.toDouble() ?? 0,

      highRiskCount: (json['highRiskCount'] as num?)?.toInt() ?? 0,

      mediumRiskCount: (json['mediumRiskCount'] as num?)?.toInt() ?? 0,

      lowRiskCount: (json['lowRiskCount'] as num?)?.toInt() ?? 0,

      defaultersCount: (json['defaultersCount'] as num?)?.toInt() ?? 0,
    );
  }
}
