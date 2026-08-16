class FaceAttendanceResultModel {
  final String recordId;
  final String sessionId;
  final String teacherId;
  final String classId;
  final String subjectId;
  final String studentId;
  final double studentLat;
  final double studentLng;
  final double distance;
  final String markedBy;
  final DateTime? markedAt;

  const FaceAttendanceResultModel({
    required this.recordId,
    required this.sessionId,
    required this.teacherId,
    required this.classId,
    required this.subjectId,
    required this.studentId,
    required this.studentLat,
    required this.studentLng,
    required this.distance,
    required this.markedBy,
    this.markedAt,
  });

  factory FaceAttendanceResultModel.fromJson(Map<String, dynamic> json) {
    return FaceAttendanceResultModel(
      recordId: json['_id'] as String,
      sessionId: _idOf(json['sessionId']),
      teacherId: _idOf(json['teacherId']),
      classId: _idOf(json['classId']),
      subjectId: _idOf(json['subjectId']),
      studentId: _idOf(json['studentId']),
      studentLat: (json['studentLat'] as num).toDouble(),
      studentLng: (json['studentLng'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      markedBy: json['markedBy'] as String,
      markedAt: json['markedAt'] != null
          ? DateTime.tryParse(json['markedAt'] as String)
          : null,
    );
  }

  static String _idOf(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value['_id'] as String;
    }

    return value as String;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': recordId,
      'sessionId': sessionId,
      'teacherId': teacherId,
      'classId': classId,
      'subjectId': subjectId,
      'studentId': studentId,
      'studentLat': studentLat,
      'studentLng': studentLng,
      'distance': distance,
      'markedBy': markedBy,
      'markedAt': markedAt?.toIso8601String(),
    };
  }
}
