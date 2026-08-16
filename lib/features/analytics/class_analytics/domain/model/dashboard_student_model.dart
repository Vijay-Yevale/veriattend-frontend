class DashboardStudentModel {
  final String studentId;
  final String userName;
  final String prn;

  final double? attendancePercentage;
  final double? performanceScore;
  final String? riskLevel;

  const DashboardStudentModel({
    required this.studentId,
    required this.userName,
    required this.prn,
    required this.attendancePercentage,
    required this.performanceScore,
    required this.riskLevel,
  });

  factory DashboardStudentModel.fromJson(Map<String, dynamic> json) {
    return DashboardStudentModel(
      studentId: json['studentId'] as String,
      userName: json['userName'] as String,
      prn: json['PRN'] as String,

      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble(),

      performanceScore: (json['performanceScore'] as num?)?.toDouble(),

      riskLevel: json['riskLevel'] as String?,
    );
  }
}
