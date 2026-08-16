class DepartmentSummaryModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final int totalSubjects;

  const DepartmentSummaryModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.totalSubjects,
  });

  factory DepartmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return DepartmentSummaryModel(
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      totalTeachers: (json['totalTeachers'] as num?)?.toInt() ?? 0,
      totalClasses: (json['totalClasses'] as num?)?.toInt() ?? 0,
      totalSubjects: (json['totalSubjects'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalClasses': totalClasses,
      'totalSubjects': totalSubjects,
    };
  }
}
