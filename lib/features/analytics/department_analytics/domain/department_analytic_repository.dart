import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_analytics_model.dart';

abstract class DepartmentAnalyticsRepository {
  Future<DepartmentAnalyticsModel> getDepartmentAnalytics({
    String? departmentId,
  });
}
