import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';

import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

import 'package:veriattend_app/features/analytics/class_analytics/presentation/providers/subject_dashboard_provider.dart';

import 'package:veriattend_app/features/analytics/class_analytics/presentation/widgets/dashboard_summary_card.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/widgets/student_analytics_card.dart';

class SubjectDashboardScreen extends ConsumerStatefulWidget {
  final String classId;
  final String subjectId;
  final String subjectName;

  const SubjectDashboardScreen({
    super.key,
    required this.classId,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  ConsumerState<SubjectDashboardScreen> createState() =>
      _SubjectDashboardScreenState();
}

class _SubjectDashboardScreenState extends ConsumerState<SubjectDashboardScreen>
    with WidgetsBindingObserver {
  SubjectDashboardParams get _params => SubjectDashboardParams(
    classId: widget.classId,
    subjectId: widget.subjectId,
  );

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
      ref.invalidate(subjectDashboardProvider(_params));
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(subjectDashboardProvider(_params));

    await ref.read(subjectDashboardProvider(_params).future);
  }

  void _goToStudentAnalytics() {
    context.push(
      AppRoutes.subjectStudents(widget.classId, widget.subjectId),
      extra: widget.subjectName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(subjectDashboardProvider(_params));

    final body = dashboard.when(
      loading: () => const AppLoader(),

      error: (error, _) {
        return AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(subjectDashboardProvider(_params));
          },
        );
      },

      data: (data) {
        if (!data.attendanceStarted) {
          final availableHeight =
              MediaQuery.of(context).size.height - kToolbarHeight;

          return RefreshIndicator(
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
                    alignment: Alignment(0, -.35),
                    child: EmptyDashboardWidget(
                      title: "Attendance not started",
                      message:
                          "No attendance sessions have been conducted for this subject yet. Student analytics will become available after the first attendance session.",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final noStudents = data.summary!.totalStudents == 0;

        if (noStudents) {
          final availableHeight =
              MediaQuery.of(context).size.height - kToolbarHeight;

          return RefreshIndicator(
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
                    alignment: Alignment(0, -.35),
                    child: EmptyDashboardWidget(
                      title: "No students available",
                      message:
                          "Students will appear here once attendance is recorded for this subject.",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPaddingH),
            children: [
              SectionCard(
                title: data.subject.subjectName,
                showArrow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.subject.subjectCode,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppSizes.md),

                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: AppSizes.iconSm,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: AppSizes.sm),

                        Expanded(
                          child: Text(
                            data.subject.teacher.userName,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              DashboardSummaryCard(summary: data.summary!),

              const SizedBox(height: AppSizes.lg),

              StudentAnalyticsCard(
                totalStudents: data.summary!.totalStudents,
                onTap: _goToStudentAnalytics,
              ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectName), centerTitle: false),
      body: body,
    );
  }
}
