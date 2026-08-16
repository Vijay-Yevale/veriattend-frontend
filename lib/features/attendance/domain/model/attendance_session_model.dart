class AttendanceSessionModel {
  final String sessionId;
  final String classId;
  final String subjectId;
  final String qrToken;
  final DateTime qrExpiry;
  final int qrVersion;
  final DateTime expiresAt;
  final bool isActive;

  const AttendanceSessionModel({
    required this.sessionId,
    required this.classId,
    required this.subjectId,
    required this.qrToken,
    required this.qrExpiry,
    required this.qrVersion,
    required this.expiresAt,
    required this.isActive,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    String idOf(dynamic field) =>
        field is Map ? field['_id'] as String : field as String;

    return AttendanceSessionModel(
      sessionId: json['_id'] as String,
      classId: idOf(json['classId']),
      subjectId: idOf(json['subjectId']),
      qrToken: json['qrToken'] as String,
      qrExpiry: DateTime.parse(json['qrExpiry'] as String),
      qrVersion: json['qrVersion'] as int? ?? 1,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  AttendanceSessionModel copyWith({
    String? qrToken,
    DateTime? qrExpiry,
    int? qrVersion,
    bool? isActive,
  }) {
    return AttendanceSessionModel(
      sessionId: sessionId,
      classId: classId,
      subjectId: subjectId,
      qrToken: qrToken ?? this.qrToken,
      qrExpiry: qrExpiry ?? this.qrExpiry,
      qrVersion: qrVersion ?? this.qrVersion,
      expiresAt: expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
