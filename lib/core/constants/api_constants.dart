class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://veriattend-backend-4qu3.onrender.com/api';

  static const String socketUrl =
      'https://veriattend-backend-4qu3.onrender.com';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  static const String myClasses = '/data/teacher/my-classes';

  static const String adminDepartments = '/admin/departments';

  static const String adminHod = '/admin/hod';

  static const String manageTeachers = '/admin/teacher';

  static const String classes = '/admin/classes';

  static const String manageSubjects = '/admin/subject';

  static const String assignTeacher = '/admin/assign-teacher';

  static const String teacherAssignments = '/admin/assign-teacher';

  static const String pendingStudents = '/admin/pending-students';

  static String studentsByClass(String classId) =>
      '/admin/students/class/$classId';

  static const String bulkAssignStudents = '/admin/bulk-assign-students';

  // ───────────────── Academics ─────────────────

  static const String addQuizMark = '/academics/quiz';

  static const String addAssignmentMark = '/academics/assignment';

  static const String setInternalMarks = '/academics/internal';

  static const String bulkSubmitMarks = '/academics/bulk';

  /// Teacher — full class roster
  static String classRoster(String classId, String subjectId) =>
      '/academics/class/$classId/subject/$subjectId/roster';

  static const String studentMarks = '/academics/student/marks';

  static String studentMarksById(String studentId) =>
      '/academics/students/$studentId/marks';

  /// Teacher → Start attendance session
  static const String startAttendanceSession = '/attendance/session/start';

  static const String submitAttendance = '/attendance/session/submit';

  /// Teacher → Manual attendance
  static String manualAttendance(String sessionId) =>
      '/attendance/session/$sessionId/manual';

  /// Teacher → Refresh QR
  static String refreshQr(String sessionId) =>
      '/attendance/session/$sessionId/refresh-qr';

  /// Teacher → End attendance session
  static String endAttendanceSession(String sessionId) =>
      '/attendance/session/$sessionId/end-session';

  /// Teacher / HOD / Student → Active session by class
  static String activeSessionByClass(String classId) =>
      '/attendance/session/active/$classId';

  /// HOD → All sessions for class
  static String allSessionsByClass(String classId) =>
      '/attendance/session/all-session/$classId';

  /// Teacher → Own session history
  static const String myTeacherSessions = '/attendance/session/teacher';

  /// HOD → Specific teacher's sessions
  static String teacherSessionsByHod(String teacherId) =>
      '/attendance/session/teacher/$teacherId';

  /// Teacher / HOD → Present students
  static String presentStudents(String sessionId) =>
      '/attendance/session/$sessionId/present-students';

  /// Teacher / HOD → Absent students
  static String absentStudents(String sessionId) =>
      '/attendance/session/$sessionId/absent-students';

  /// Teacher / HOD → Session review
  static String sessionReview(String sessionId) =>
      '/attendance/session/$sessionId/review';

  /// Teacher / HOD → Live session summary
  static String sessionLiveSummary(String sessionId) =>
      '/attendance/session/$sessionId/live';

  /// Teacher → Remove attendance record
  static String removeAttendanceRecord(String recordId) =>
      '/attendance/session/$recordId/remove-record';

  static String verifyFaceAttendance = '/attendance/session/verify-face';

  //  Face Recognition

  /// Student → Enroll / update face embedding
  static const String faceEnroll = '/face/enroll';

  /// Student → Get face profile
  static const String faceProfile = '/face/profile';

  /// Student → Check whether face is registered
  static const String faceStatus = '/face/status';

  //  Analytics

  static const String studentDashboard = '/analytics/student/dashboard';

  static String studentDashboardById(String studentId) =>
      '/analytics/students/$studentId/dashboard';

  static String departmentAnalytics([String? departmentId]) {
    return departmentId == null
        ? '/analytics/department'
        : '/analytics/department/$departmentId';
  }

  static String classDashboard(String classId) => '/analytics/class/$classId';

  static String subjectDashboard(String classId, String subjectId) =>
      '/analytics/class/$classId?subjectId=$subjectId';

  static String studentSubjectDetail(String studentId, String subjectId) =>
      '/analytics/student/$studentId/subject/$subjectId';

  //  Information / Data

  static String classDetail(String classId) => '/data/class/$classId';

  //  Timetable

  static const String timetable = '/timetable';

  /// POST /timetable
  static const String createTimetableSlot = '/timetable';

  /// Student timetable
  static const String myClassTimetable = '/timetable/class';

  /// Teacher timetable
  static const String myTeacherTimetable = '/timetable/teacher';

  /// Student active slot
  static const String myActiveClassSlot = '/timetable/class/active';

  /// Teacher active slot
  static const String myActiveTeacherSlot = '/timetable/active';

  /// HOD → class timetable
  static String timetableByClass(String classId) => '/timetable/class/$classId';

  /// HOD → teacher timetable
  static String timetableByTeacher(String teacherId) =>
      '/timetable/teacher/$teacherId';

  /// HOD → class active slot
  static String activeSlotByClass(String classId) =>
      '/timetable/class/$classId/active';

  /// PATCH
  static String updateTimetableSlot(String slotId) => '/timetable/$slotId';

  /// DELETE
  static String deleteTimetableSlot(String slotId) => '/timetable/$slotId';

  //  Academic Constants

  static const double quizMax = 10;
  static const double assignmentMax = 25;
  static const double internalMax = 30;
}
