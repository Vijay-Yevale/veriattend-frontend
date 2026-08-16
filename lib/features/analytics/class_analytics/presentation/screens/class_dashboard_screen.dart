import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';

import 'package:veriattend_app/features/analytics/class_analytics/presentation/providers/class_analytics_provider.dart';

import 'package:veriattend_app/features/analytics/class_analytics/presentation/widgets/available_subject_card.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/widgets/dashboard_summary_card.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/widgets/student_analytics_card.dart';

class ClassDashboardScreen extends ConsumerStatefulWidget {
  final String classId;

  const ClassDashboardScreen({super.key, required this.classId});

  @override
  ConsumerState<ClassDashboardScreen> createState() =>
      _ClassDashboardScreenState();
}

class _ClassDashboardScreenState extends ConsumerState<ClassDashboardScreen>
    with WidgetsBindingObserver {
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
      ref.invalidate(classDashboardProvider(widget.classId));
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(classDashboardProvider(widget.classId));
    await ref.read(classDashboardProvider(widget.classId).future);
  }

  void _goToStudentAnalytics() {
    context.push(AppRoutes.studentAnalyticsList(widget.classId));
  }

  void _goToSubjectDashboard({
    required String subjectId,
    required String subjectName,
  }) {
    context.push(
      AppRoutes.subjectDashboard(widget.classId, subjectId),
      extra: subjectName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(classDashboardProvider(widget.classId));

    final body = dashboard.when(
      loading: () => const AppLoader(),

      error: (error, _) {
        return AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(classDashboardProvider(widget.classId));
          },
        );
      },

      data: (data) {
        final totalStudents = data.summary?.totalStudents ?? 0;
        final noStudents = totalStudents == 0;

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
                          "Students will appear here once they are assigned to this class.",
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
              DashboardSummaryCard(summary: data.summary!),

              const SizedBox(height: AppSizes.lg),

              StudentAnalyticsCard(
                totalStudents: totalStudents,
                onTap: _goToStudentAnalytics,
              ),

              const SizedBox(height: AppSizes.xl),

              Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: AppSizes.iconSm,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(width: AppSizes.sm),

                  Text(
                    "Subjects",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              if (data.availableSubjects.isEmpty)
                const EmptyDashboardWidget(
                  title: "No subjects available",
                  message:
                      "Subjects will appear here once they are assigned to this class.",
                )
              else
                ...data.availableSubjects.map(
                  (subject) => AvailableSubjectCard(
                    subject: subject,
                    onTap: () {
                      _goToSubjectDashboard(
                        subjectId: subject.subjectId,
                        subjectName: subject.subjectName,
                      );
                    },
                  ),
                ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(dashboard.asData?.value.className ?? "Class Analytics"),
        centerTitle: false,
      ),
      body: body,
    );
  }
}
