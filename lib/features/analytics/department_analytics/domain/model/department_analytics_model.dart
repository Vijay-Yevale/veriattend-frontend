import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_class_model.dart';
import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_summary_model.dart';

class DepartmentAnalyticsModel {
  final String departmentId;
  final String departmentName;
  final DepartmentSummaryModel summary;
  final List<DepartmentClassModel> classes;

  const DepartmentAnalyticsModel({
    required this.departmentId,
    required this.departmentName,
    required this.summary,
    required this.classes,
  });

  factory DepartmentAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DepartmentAnalyticsModel(
      departmentId: json['departmentId'] as String,
      departmentName: json['departmentName'] as String,

      summary: DepartmentSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),

      classes: (json['classes'] as List<dynamic>)
          .map((e) => DepartmentClassModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentId': departmentId,
      'departmentName': departmentName,
      'summary': summary.toJson(),
      'classes': classes.map((e) => e.toJson()).toList(),
    };
  }
}
