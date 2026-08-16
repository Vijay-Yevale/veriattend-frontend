class BulkSubmitFailureModel {
  final String studentId;
  final String reason;

  const BulkSubmitFailureModel({required this.studentId, required this.reason});

  factory BulkSubmitFailureModel.fromJson(Map<String, dynamic> json) {
    return BulkSubmitFailureModel(
      studentId: json['studentId'] as String,
      reason: json['reason'] as String,
    );
  }
}

class BulkSubmitResultModel {
  final List<String> updated;
  final List<BulkSubmitFailureModel> failed;

  const BulkSubmitResultModel({required this.updated, required this.failed});

  factory BulkSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return BulkSubmitResultModel(
      updated: (json['updated'] as List<dynamic>? ?? const [])
          .map((id) => id as String)
          .toList(),
      failed: (json['failed'] as List<dynamic>? ?? const [])
          .map(
            (f) => BulkSubmitFailureModel.fromJson(f as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
