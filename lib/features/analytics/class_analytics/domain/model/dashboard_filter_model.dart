class DashboardFiltersModel {
  final List<String> highRisk;
  final List<String> mediumRisk;
  final List<String> lowRisk;
  final List<String> defaulters;

  const DashboardFiltersModel({
    required this.highRisk,
    required this.mediumRisk,
    required this.lowRisk,
    required this.defaulters,
  });

  const DashboardFiltersModel.empty()
    : highRisk = const [],
      mediumRisk = const [],
      lowRisk = const [],
      defaulters = const [];

  factory DashboardFiltersModel.fromJson(Map<String, dynamic> json) {
    List<String> parseIds(String key) {
      final value = json[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return DashboardFiltersModel(
      highRisk: parseIds('highRisk'),
      mediumRisk: parseIds('mediumRisk'),
      lowRisk: parseIds('lowRisk'),
      defaulters: parseIds('defaulters'),
    );
  }
}
