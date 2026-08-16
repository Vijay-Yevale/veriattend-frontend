import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/alert_banner.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/providers/student_analytics_provider.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/attendance_card.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/subject_attendance_card.dart';

class AttendanceDetailScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const AttendanceDetailScreen({super.key, this.studentId});

  @override
  ConsumerState<AttendanceDetailScreen> createState() =>
      _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends ConsumerState<AttendanceDetailScreen>
    with WidgetsBindingObserver {
  bool get _isOwnDashboard => widget.studentId == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(studentAnalyticsProvider(widget.studentId));
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(studentAnalyticsProvider(widget.studentId));
    await ref.read(studentAnalyticsProvider(widget.studentId).future);
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(studentAnalyticsProvider(widget.studentId));

    final body = analytics.when(
      loading: () => const AppLoader(),

      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () =>
            ref.invalidate(studentAnalyticsProvider(widget.studentId)),
      ),

      data: (data) {
        final attendance = data.attendance;

        final subjects = [...attendance.subjectWise]
          ..sort((a, b) {
            final compare = a.attendancePercentage.compareTo(
              b.attendancePercentage,
            );

            if (compare != 0) return compare;

            return a.subjectName.compareTo(b.subjectName);
          });

        if (!attendance.hasData) {
          final availableHeight =
              MediaQuery.of(context).size.height -
              kToolbarHeight -
              kBottomNavigationBarHeight;

          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenPaddingH,
              ),
              children: [
                SizedBox(
                  height: availableHeight,
                  child: const Align(
                    alignment: Alignment(0, -0.35),
                    child: EmptyDashboardWidget(
                      title: "Attendance not available",
                      message:
                          "Attendance details will appear here once classes have been conducted.",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPaddingH),
            children: [
              // Overall warning
              if (attendance.classesNeededFor75 > 0) ...[
                AlertBanner(
                  type: BannerType.warning,
                  message:
                      "Attend ${attendance.classesNeededFor75} more classes to reach 75% attendance.",
                ),
                const SizedBox(height: AppSizes.md),
              ],

              // Overall Attendance
              AttendanceCard(attendance: attendance),

              const SizedBox(height: AppSizes.xl),

              // Subject Attendance Heading
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: AppSizes.sm),
                child: Text(
                  "Subject Attendance",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              // Subject List
              if (subjects.isEmpty)
                SizedBox(
                  height: 300,
                  child: const Center(
                    child: EmptyDashboardWidget(
                      title: "No Subject Attendance",
                      message:
                          "Subject-wise attendance will appear here once attendance records become available.",
                    ),
                  ),
                )
              else
                ...subjects.map(
                  (subject) => SubjectAttendanceCard(subject: subject),
                ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    if (_isOwnDashboard) {
      return AppScaffold(
        title: "Attendance Details",
        navItems: StudentNavItems.items,
        currentRoute: AppRoutes.student,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Attendance Details"),
        centerTitle: false,
      ),
      body: body,
    );
  }
}
