import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';

import 'package:veriattend_app/core/widgets/alert_banner.dart';

import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/greeting_section.dart';

import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/academic_card.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/attendance_card.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/risk_card.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

import '../providers/student_analytics_provider.dart';

class StudentAnalyticsDashboard extends ConsumerStatefulWidget {
  final String? studentId;

  const StudentAnalyticsDashboard({super.key, this.studentId});

  @override
  ConsumerState<StudentAnalyticsDashboard> createState() =>
      _StudentAnalyticsDashboardState();
}

class _StudentAnalyticsDashboardState
    extends ConsumerState<StudentAnalyticsDashboard>
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

  void _goToAttendanceDetail() {
    context.push(
      widget.studentId == null
          ? AppRoutes.studentAttendance
          : AppRoutes.studentAttendanceDetail(widget.studentId!),
    );
  }

  void _goToAcademicDetail() {
    context.push(
      widget.studentId == null
          ? AppRoutes.studentAcademic
          : AppRoutes.studentAcademicDetail(widget.studentId!),
    );
  }

  void _goToRiskDetail() {
    context.push(
      widget.studentId == null
          ? AppRoutes.studentRisk
          : AppRoutes.studentRiskDetail(widget.studentId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(studentAnalyticsProvider(widget.studentId));

    Widget? greetingWidget;
    if (_isOwnDashboard) {
      final authState = ref.watch(authProvider);
      final studentName = switch (authState) {
        AuthAuthenticated(user: final user) => user.userName,
        _ => 'Student',
      };
      greetingWidget = GreetingSection(
        userName: studentName,
        subtitle: "Here's your academic overview",
      );
    }

    final body = analytics.when(
      loading: () => Column(
        children: [
          if (greetingWidget != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPaddingH,
                AppSizes.md,
                AppSizes.screenPaddingH,
                0,
              ),
              child: greetingWidget,
            ),
          const Expanded(child: AppLoader()),
        ],
      ),
      error: (e, _) => Column(
        children: [
          if (greetingWidget != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPaddingH,
                AppSizes.md,
                AppSizes.screenPaddingH,
                0,
              ),
              child: greetingWidget,
            ),
          Expanded(
            child: AppErrorWidget(
              message: e.toString(),
              onRetry: () =>
                  ref.invalidate(studentAnalyticsProvider(widget.studentId)),
            ),
          ),
        ],
      ),
      data: (data) {
        final attendance = data.attendance;
        final risk = data.risk;
        final academic = data.academicMarks;

        final hasAttendance = attendance.hasData;
        final hasAcademic = academic?.hasData ?? false;
        final hasRisk = risk.hasData;

        final noDashboardData = !hasAttendance && !hasAcademic && !hasRisk;

        if (noDashboardData) {
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
                if (greetingWidget != null) ...[
                  const SizedBox(height: AppSizes.md),
                  greetingWidget,
                  const SizedBox(height: AppSizes.lg),
                ],
                SizedBox(
                  height: availableHeight,
                  child: const Align(
                    alignment: Alignment(0, -0.35),
                    child: EmptyDashboardWidget(
                      title: "No analytics available yet",
                      message:
                          "Your attendance, academic performance, and risk analysis will appear here once your records become available.",
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
              if (greetingWidget != null) ...[
                greetingWidget,
                const SizedBox(height: AppSizes.lg),
              ],

              // Attendance
              if (hasAttendance) ...[
                if (attendance.classesNeededFor75 > 0) ...[
                  AlertBanner(
                    type: BannerType.warning,
                    message:
                        "Attend ${attendance.classesNeededFor75} more classes to reach 75% attendance.",
                  ),
                  const SizedBox(height: AppSizes.md),
                ],

                AttendanceCard(
                  attendance: attendance,
                  onTap: _goToAttendanceDetail,
                ),
              ] else
                const AlertBanner(
                  type: BannerType.info,
                  message: "Attendance has not been recorded yet.",
                ),

              const SizedBox(height: AppSizes.lg),

              // Academic
              if (hasAcademic)
                AcademicCard(academic: academic!, onTap: _goToAcademicDetail)
              else
                const AlertBanner(
                  type: BannerType.info,
                  message: "Academic marks have not been entered yet.",
                ),

              const SizedBox(height: AppSizes.lg),

              // Risk
              if (hasRisk) ...[
                if (risk.riskLevel == "HIGH") ...[
                  const AlertBanner(
                    type: BannerType.error,
                    message:
                        " currently at high academic risk. Review  weak subjects.",
                  ),
                  const SizedBox(height: AppSizes.md),
                ],

                RiskCard(risk: risk, onTap: _goToRiskDetail),
              ] else
                const AlertBanner(
                  type: BannerType.info,
                  message:
                      "Risk analysis will be available once sufficient academic data is available.",
                ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    if (_isOwnDashboard) {
      return AppScaffold(
        title: 'Student Analytics',
        navItems: StudentNavItems.items,
        currentRoute: AppRoutes.student,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Student Analytics'),
        centerTitle: false,
      ),
      body: body,
    );
  }
}
