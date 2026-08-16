// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/screens/admin_dashboard_screen.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/screens/admin_manage_screen.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/screens/class_dashboard_screen.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/screens/student_analytic_list_screen.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/screens/student_subject_detail_screen.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/screens/subject_dashboard_screen.dart';
import 'package:veriattend_app/features/analytics/department_analytics/presentation/screens/department_analytics_screen.dart';

import 'package:veriattend_app/features/analytics/studentanalytics/presentation/screens/academic_detail_screen.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/screens/attendance_detail_screen.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/screens/risk_detail_screen.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/screens/student_analytics_dashboard.dart';
import 'package:veriattend_app/features/attendance/presentation/screens/attendance_review_screen.dart';
import 'package:veriattend_app/features/attendance/presentation/screens/face_verifaction_screen.dart';
import 'package:veriattend_app/features/attendance/presentation/screens/student_qr_scanner_screen.dart';
import 'package:veriattend_app/features/attendance/presentation/screens/student_scan_screen.dart';
import 'package:veriattend_app/features/attendance/presentation/screens/teacher_session_history_screen.dart';
import 'package:veriattend_app/features/attendance/presentation/screens/teacher_session_screen.dart';
import 'package:veriattend_app/features/attendance/presentation/widgets/attendance_full_screen_view.dart';
import 'package:veriattend_app/features/face/presentation/screens/face_enrollement_screen.dart';

import 'package:veriattend_app/features/hod/presentation/screens/assign_stundent_screen.dart';
import 'package:veriattend_app/features/hod/presentation/screens/class_management_screen.dart';
import 'package:veriattend_app/features/hod/presentation/screens/hod_timetable_screen.dart';
import 'package:veriattend_app/features/hod/presentation/screens/manage_screen.dart';
import 'package:veriattend_app/features/hod/presentation/screens/subject_management_screen.dart';
import 'package:veriattend_app/features/hod/presentation/screens/teacher_assign_management_screen.dart';
import 'package:veriattend_app/features/hod/presentation/screens/teacher_management_screen.dart';
import 'package:veriattend_app/features/teacher/presentation/screens/manage_mark_screen.dart';
import 'package:veriattend_app/features/teacher/presentation/screens/teacher_home_screen.dart';
import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';
import 'package:veriattend_app/features/timetable/presentation/screens/class_timetable_screen.dart';
import 'package:veriattend_app/features/timetable/presentation/screens/teacher_timetable_screen.dart';
import 'package:veriattend_app/features/timetable/presentation/screens/timetable_management_screen.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';

  static const login = '/login';
  static const register = '/register';

  static const student = '/student';
  static const studentAcademic = '/student/academic';
  static const studentRisk = '/student/risk';
  static const studentAttendance = '/student/attendance';

  static const studentTimetable = '/student/timetable';
  static const studentProfile = '/student/profile';

  static const teacher = '/teacher';
  static const teacherTimetable = '/teacher/timetable';
  static const teacherManage = '/teacher/manage';
  static const teacherSession = '/teacher/session';
  static const teacherProfile = '/teacher/profile';

  static const hod = '/hod';
  static const hodClasses = '/hod/classes';
  static const hodTeachers = '/hod/teacher';
  static const hodSubjects = '/hod/subject';
  static const hodAssignTeacher = '/hod/assign-teacher';
  static const hodAssignStudents = '/hod/assign-students';

  static const hodmanage = '/hod/manage';
  static const hodProfile = '/hod/profile';

  // Timetable
  static const hodTimetable = "/hod/timetable";

  static const myTimetableRoute = "/timetable";
  static const classTimetableRoute = "/timetable/class/:classId";

  static String classTimetable(String classId) => "/timetable/class/$classId";

  // HOD → a specific teacher's timetable (read-only). Named

  /// Teacher → Live attendance session
  static const String teacherSessionRoute = '/teacher/session';

  /// Teacher → Attendance session history
  static const String teacherSessionHistoryRoute = '/teacher/session-history';

  /// Teacher → Full-screen QR
  static const String attendanceFullScreenQrRoute =
      '/teacher/session/qr-fullscreen';

  static const String attendanceReviewRoute =
      '/teacher/session/:sessionId/review';

  static String attendanceReview(String sessionId) =>
      '/teacher/session/$sessionId/review';

  /// Student QR Scanner
  static const studentScanQrRoute = '/student/scan';
  static const studentQrScannerRoute = '/student/scan/scanner';

  //   Face Recognition

  // Student → Enroll / re-enroll face (register embedding)
  static const String studentFaceEnrollRoute = '/student/face/enroll';

  // Student → View face registration status, re-enroll from here too
  static const String studentFaceProfileRoute = '/student/face/profile';

  // Student → Live face capture step, inside the QR scan flow, right
  // before attendance gets submitted
  static const String studentFaceVerifyRoute = '/student/scan/face-verify';

  static const teacherTimetableRoute = "/timetable/teacher/:teacherId";

  static String teacherTimetableFor(String teacherId) =>
      "/timetable/teacher/$teacherId";

  static const timetableManageRoute = "/timetable/manage";

  static const admin = '/admin';
  static const adminManage = '/admin/manage';
  static const adminProfile = '/admin/profile';

  // Department (not yet wired up — left commented in routes list)
  static const departmentAnalyticsRoute =
      '/analytics/departments/:departmentId';

  static String departmentAnalytics(String departmentId) =>
      '/analytics/departments/$departmentId';

  // Class Dashboard
  static const classDashboardRoute = '/analytics/classes/:classId';

  static String classDashboard(String classId) => '/analytics/classes/$classId';

  // Student Analytics List (class mode — no subject)
  static const studentAnalyticsListRoute =
      '/analytics/classes/:classId/students';

  static String studentAnalyticsList(String classId) =>
      '/analytics/classes/$classId/students';

  // Subject Dashboard (subject view within a class)
  static const subjectDashboardRoute =
      '/analytics/classes/:classId/subjects/:subjectId';

  static String subjectDashboard(String classId, String subjectId) =>
      '/analytics/classes/$classId/subjects/$subjectId';

  // Subject Students (student list scoped to one subject)
  static const subjectStudentsRoute =
      '/analytics/classes/:classId/subjects/:subjectId/students';

  static String subjectStudents(String classId, String subjectId) =>
      '/analytics/classes/$classId/subjects/$subjectId/students';

  // Student Dashboard
  static const studentDashboardRoute =
      '/analytics/students/:studentId/dashboard';

  static String studentDashboard(String studentId) =>
      '/analytics/students/$studentId/dashboard';

  // Student Attendance Detail
  static const studentAttendanceDetailRoute =
      '/analytics/students/:studentId/attendance';

  static String studentAttendanceDetail(String studentId) =>
      '/analytics/students/$studentId/attendance';

  // Student Academic Detail
  static const studentAcademicDetailRoute =
      '/analytics/students/:studentId/academic';

  static String studentAcademicDetail(String studentId) =>
      '/analytics/students/$studentId/academic';

  // Student Risk Detail
  static const studentRiskDetailRoute = '/analytics/students/:studentId/risk';

  static String studentRiskDetail(String studentId) =>
      '/analytics/students/$studentId/risk';

  // Student Subject Detail
  static const studentSubjectDetailRoute =
      '/analytics/students/:studentId/subjects/:subjectId';

  static String studentSubjectDetail(String studentId, String subjectId) =>
      '/analytics/students/$studentId/subjects/$subjectId';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = RouterNotifier(ref);
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: authNotifier._redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: AppRoutes.hod,
        builder: (context, state) => const DepartmentAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodmanage,
        builder: (context, state) => const ManageScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodTeachers,
        builder: (context, state) => const TeacherManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodClasses,
        builder: (context, state) => const ClassManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodSubjects,
        builder: (context, state) => const SubjectManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodAssignTeacher,
        builder: (context, state) => const TeacherAssignmentScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodAssignStudents,
        builder: (context, state) => const AssignStudentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodTimetable,
        builder: (context, state) => const HodTimetableScreen(),
      ),
      GoRoute(
        path: AppRoutes.hodProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.myTimetableRoute,
        builder: (_, __) {
          final authState = ref.read(authProvider);
          final role = authState is AuthAuthenticated
              ? authState.user.role
              : null;

          if (role == 'TEACHER') {
            return const TeacherTimetableScreen();
          }

          return const ClassTimetableScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.classTimetableRoute,
        builder: (context, state) {
          final classId = state.pathParameters["classId"]!;

          return ClassTimetableScreen(classId: classId);
        },
      ),

      GoRoute(
        path: AppRoutes.teacherTimetableRoute,
        builder: (context, state) {
          final teacherId = state.pathParameters["teacherId"]!;
          final teacherName = state.extra as String?;

          return TeacherTimetableScreen(
            teacherId: teacherId,
            teacherName: teacherName,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.teacherManage,
        builder: (context, state) => ManageMarksScreen(),
      ),

      GoRoute(
        path: AppRoutes.timetableManageRoute,
        builder: (context, state) {
          final args = state.extra as TimetableManageArgs;

          return TimetableManagementScreen(
            classId: args.classId,
            slot: args.slot,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.teacherSessionRoute,
        builder: (context, state) {
          final slot = state.extra as TimetableSlotModel;

          return TeacherSessionScreen(slot: slot);
        },
      ),

      GoRoute(
        path: AppRoutes.attendanceFullScreenQrRoute,
        builder: (context, state) {
          return const AttendanceFullScreenQrView();
        },
      ),

      GoRoute(
        path: AppRoutes.teacherSessionHistoryRoute,
        builder: (context, state) => const TeacherSessionHistoryScreen(),
      ),

      GoRoute(
        path: AppRoutes.attendanceReviewRoute,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;

          return AttendanceReviewScreen(sessionId: sessionId);
        },
      ),

      GoRoute(
        path: AppRoutes.student,
        builder: (context, state) => const StudentAnalyticsDashboard(),
      ),
      GoRoute(
        path: AppRoutes.studentTimetable,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Student Timetable'))),
      ),
      GoRoute(
        path: AppRoutes.studentScanQrRoute,
        builder: (context, state) => const StudentScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentQrScannerRoute,
        builder: (context, state) => const StudentQrScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentFaceVerifyRoute,
        builder: (context, state) {
          final verificationToken = state.extra as String;

          return FaceVerificationScreen(verificationToken: verificationToken);
        },
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // add inside the routes list — I'd put it near the other student routes
      GoRoute(
        path: AppRoutes.studentFaceEnrollRoute,
        builder: (context, state) => const FaceEnrollmentScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAttendance,
        builder: (context, state) =>
            const AttendanceDetailScreen(studentId: null),
      ),
      GoRoute(
        path: AppRoutes.studentAcademic,
        builder: (context, state) =>
            const AcademicDetailScreen(studentId: null),
      ),
      GoRoute(
        path: AppRoutes.studentRisk,
        builder: (context, state) => const RiskDetailScreen(studentId: null),
      ),

      // Teacher
      GoRoute(
        path: AppRoutes.teacher,

        builder: (context, state) => const TeacherHomeScreen(),
      ),

      GoRoute(
        path: AppRoutes.teacherProfile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // admin route
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) {
          return const AdminDashboardScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.adminManage,
        builder: (context, state) {
          return const AdminManageScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.adminProfile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Analytics

      // Class Dashboard
      GoRoute(
        path: AppRoutes.classDashboardRoute,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;

          return ClassDashboardScreen(classId: classId);
        },
      ),

      // Student Analytics List (class mode)
      GoRoute(
        path: AppRoutes.studentAnalyticsListRoute,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;

          return StudentAnalyticsListScreen(classId: classId);
        },
      ),

      // Subject Dashboard
      GoRoute(
        path: AppRoutes.subjectDashboardRoute,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          final subjectId = state.pathParameters['subjectId']!;

          final subjectName = state.extra as String? ?? '';

          return SubjectDashboardScreen(
            classId: classId,
            subjectId: subjectId,
            subjectName: subjectName,
          );
        },
      ),

      // Subject Students (student list scoped to one subject)
      GoRoute(
        path: AppRoutes.subjectStudentsRoute,
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          final subjectId = state.pathParameters['subjectId']!;
          final subjectName = state.extra as String?;

          return StudentAnalyticsListScreen(
            classId: classId,
            subjectId: subjectId,
            subjectName: subjectName,
          );
        },
      ),

      // Student Dashboard (Admin/HOD viewing a specific student)
      GoRoute(
        path: AppRoutes.studentDashboardRoute,
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;

          return StudentAnalyticsDashboard(studentId: studentId);
        },
      ),

      // Student Attendance Detail
      GoRoute(
        path: AppRoutes.studentAttendanceDetailRoute,
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;

          return AttendanceDetailScreen(studentId: studentId);
        },
      ),

      // Student Academic Detail
      GoRoute(
        path: AppRoutes.studentAcademicDetailRoute,
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;

          return AcademicDetailScreen(studentId: studentId);
        },
      ),

      // Student Risk Detail
      GoRoute(
        path: AppRoutes.studentRiskDetailRoute,
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;

          return RiskDetailScreen(studentId: studentId);
        },
      ),

      // Student Subject Detail
      GoRoute(
        path: AppRoutes.studentSubjectDetailRoute,
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;
          final subjectId = state.pathParameters['subjectId']!;

          final subjectName = state.extra as String?;

          return StudentSubjectDetailScreen(
            studentId: studentId,
            subjectId: subjectId,
            subjectName: subjectName,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.departmentAnalyticsRoute,
        builder: (context, state) {
          final departmentId = state.pathParameters['departmentId']!;

          return DepartmentAnalyticsScreen(departmentId: departmentId);
        },
      ),
    ],
  );
});

// ROUTE NOTIFIER
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final currentPath = state.uri.path;
    print("========== REDIRECT ==========");
    print(authState.runtimeType);
    print(state.uri.path);
    final isOnAuthPage =
        currentPath == AppRoutes.login || currentPath == AppRoutes.register;

    // still checking → stay on splash
    if (authState is AuthInitial || authState is AuthLoading) {
      return currentPath == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // network error → stay on splash
    if (authState is AuthError) {
      return currentPath == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // no token → go to login
    if (authState is AuthUnauthenticated) {
      return isOnAuthPage ? null : AppRoutes.login;
    }

    // logged in → block auth + splash
    if (authState is AuthAuthenticated) {
      if (isOnAuthPage || currentPath == AppRoutes.splash) {
        return _dashboardByRole(authState.user.role);
      }
    }

    return null;
  }

  String _dashboardByRole(String role) {
    switch (role) {
      case 'STUDENT':
        return AppRoutes.student;
      case 'TEACHER':
        return AppRoutes.teacher;
      case 'HOD':
        return AppRoutes.hod;
      case 'SUPER_ADMIN':
        return AppRoutes.admin;
      default:
        return AppRoutes.login;
    }
  }
}
