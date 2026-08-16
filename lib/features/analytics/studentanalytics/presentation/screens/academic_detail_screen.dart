import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/providers/student_analytics_provider.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/academic_card.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/subject_mark_card.dart';

class AcademicDetailScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const AcademicDetailScreen({super.key, this.studentId});

  @override
  ConsumerState<AcademicDetailScreen> createState() =>
      _AcademicDetailScreenState();
}

class _AcademicDetailScreenState extends ConsumerState<AcademicDetailScreen>
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
      ref.invalidate(studentMarksProvider(widget.studentId));
      ref.invalidate(studentAnalyticsProvider(widget.studentId));
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(studentMarksProvider(widget.studentId));
    ref.invalidate(studentAnalyticsProvider(widget.studentId));

    await Future.wait([
      ref.read(studentMarksProvider(widget.studentId).future),
      ref.read(studentAnalyticsProvider(widget.studentId).future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final marksAsync = ref.watch(studentMarksProvider(widget.studentId));
    final analyticsAsync = ref.watch(
      studentAnalyticsProvider(widget.studentId),
    );

    final body = analyticsAsync.when(
      loading: () => const AppLoader(),

      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () {
          ref.invalidate(studentAnalyticsProvider(widget.studentId));
          ref.invalidate(studentMarksProvider(widget.studentId));
        },
      ),

      data: (analytics) {
        final academic = analytics.academicMarks;

        return marksAsync.when(
          loading: () => const AppLoader(),

          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () {
              ref.invalidate(studentMarksProvider(widget.studentId));
              ref.invalidate(studentAnalyticsProvider(widget.studentId));
            },
          ),

          data: (subjects) {
            if (academic == null && subjects.isEmpty) {
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
                          title: "Academic records not available",
                          message:
                              "Academic records will appear here once teachers publish your marks.",
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final sortedSubjects = [...subjects]
              ..sort(
                (a, b) => a.subjectName.toLowerCase().compareTo(
                  b.subjectName.toLowerCase(),
                ),
              );

            return RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.screenPaddingH),
                children: [
                  // Overall Academic Summary
                  if (academic != null) ...[
                    AcademicCard(academic: academic),

                    if (sortedSubjects.isNotEmpty)
                      const SizedBox(height: AppSizes.xl),
                  ],

                  // Subject-wise Marks
                  if (sortedSubjects.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Text(
                        "Subject Marks",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),

                    ...sortedSubjects.map(
                      (subject) => SubjectMarkCard(subject: subject),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSizes.md),

                    const EmptyDashboardWidget(
                      title: "No Subject Marks",
                      message:
                          "Subject-wise marks have not been published yet.",
                    ),
                  ],

                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            );
          },
        );
      },
    );

    if (_isOwnDashboard) {
      return AppScaffold(
        title: "Academic Details",
        navItems: StudentNavItems.items,
        currentRoute: AppRoutes.student,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Academic Details"), centerTitle: false),
      body: body,
    );
  }
}
