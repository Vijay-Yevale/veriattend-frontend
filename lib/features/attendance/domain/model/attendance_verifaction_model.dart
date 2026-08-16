class AttendanceVerificationModel {
  final String sessionId;
  final bool verified;
  final double distance;
  final String verificationToken;
  final int expiresIn;

  const AttendanceVerificationModel({
    required this.sessionId,
    required this.verified,
    required this.distance,
    required this.verificationToken,
    required this.expiresIn,
  });

  factory AttendanceVerificationModel.fromJson(Map<String, dynamic> json) {
    return AttendanceVerificationModel(
      sessionId: _idOf(json['sessionId']),
      verified: json['verified'] as bool,
      distance: (json['distance'] as num).toDouble(),
      verificationToken: json['verificationToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
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
      'sessionId': sessionId,
      'verified': verified,
      'distance': distance,
      'verificationToken': verificationToken,
      'expiresIn': expiresIn,
    };
  }
}
