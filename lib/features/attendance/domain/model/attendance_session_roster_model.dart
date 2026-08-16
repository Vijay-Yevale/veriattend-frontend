enum RosterStatus { present, absent }

class RosterEntryModel {
  final String studentId;
  final String userName;
  final String? prn;
  final RosterStatus status;
  final bool manualAllowed;
  final String? markedBy; // "SELF" | "TEACHER"
  final String? reason;
  final DateTime? markedAt;

  const RosterEntryModel({
    required this.studentId,
    required this.userName,
    this.prn,
    required this.status,
    required this.manualAllowed,
    this.markedBy,
    this.reason,
    this.markedAt,
  });

  factory RosterEntryModel.fromJson(Map<String, dynamic> json) {
    return RosterEntryModel(
      studentId: json['studentId'] as String,
      userName: json['userName'] as String,
      prn: json['PRN'] as String?,
      status: (json['status'] as String) == 'PRESENT'
          ? RosterStatus.present
          : RosterStatus.absent,
      manualAllowed: json['manualAllowed'] as bool? ?? false,
      markedBy: json['markedBy'] as String?,
      reason: json['reason'] as String?,
      markedAt: json['markedAt'] != null
          ? DateTime.tryParse(json['markedAt'] as String)
          : null,
    );
  }
}

class SessionRosterModel {
  final String sessionId;
  final bool sessionActive;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final List<RosterEntryModel> roster;

  const SessionRosterModel({
    required this.sessionId,
    required this.sessionActive,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.roster,
  });

  factory SessionRosterModel.fromJson(Map<String, dynamic> json) {
    return SessionRosterModel(
      sessionId: json['sessionId'] as String,
      sessionActive: json['sessionActive'] as bool? ?? false,
      totalStudents: json['totalStudents'] as int? ?? 0,
      presentCount: json['presentCount'] as int? ?? 0,
      absentCount: json['absentCount'] as int? ?? 0,
      roster: (json['roster'] as List<dynamic>? ?? [])
          .map((e) => RosterEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  List<RosterEntryModel> get presentList =>
      roster.where((r) => r.status == RosterStatus.present).toList();

  List<RosterEntryModel> get absentList =>
      roster.where((r) => r.status == RosterStatus.absent).toList();
}
