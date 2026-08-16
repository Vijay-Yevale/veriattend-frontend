// lib/core/enums/attendance_status.dart
//
// Mirrors the computed `status` field in attendanceSession.service.js ->
// getSessionReview's roster rows ("PRESENT" if a Record exists for that
// student in the session, "ABSENT" otherwise).

enum AttendanceStatus { present, absent }

extension AttendanceStatusExtension on AttendanceStatus {
  static AttendanceStatus fromApi(String value) {
    switch (value) {
      case 'PRESENT':
        return AttendanceStatus.present;
      case 'ABSENT':
        return AttendanceStatus.absent;
      default:
        throw ArgumentError('Unknown status value: $value');
    }
  }

  String get apiValue {
    switch (this) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.absent:
        return 'ABSENT';
    }
  }
}
