// lib/core/enums/marked_by.dart
//
// Mirrors attendanceRecord.model's `markedBy` field: "SELF" when the
// student scans the QR themselves, "TEACHER" when marked manually via
// attendanceSession.service.js -> manualAttendance.

enum MarkedBy { self, teacher }

extension MarkedByExtension on MarkedBy {
  static MarkedBy fromApi(String value) {
    switch (value) {
      case 'SELF':
        return MarkedBy.self;
      case 'TEACHER':
        return MarkedBy.teacher;
      default:
        throw ArgumentError('Unknown markedBy value: $value');
    }
  }

  String get apiValue {
    switch (this) {
      case MarkedBy.self:
        return 'SELF';
      case MarkedBy.teacher:
        return 'TEACHER';
    }
  }
}
