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
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/risk_card.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/subject_performance_card.dart';

class RiskDetailScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const RiskDetailScreen({super.key, this.studentId});

  @override
  ConsumerState<RiskDetailScreen> createState() => _RiskDetailScreenState();
}

class _RiskDetailScreenState extends ConsumerState<RiskDetailScreen>
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
        final risk = data.risk;

        // ML hasn't generated a prediction yet.
        if (!risk.hasData) {
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
                      title: "Risk analysis not available",
                      message:
                          "Risk analysis will appear once sufficient academic data becomes available.",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final weakSubjects = [...risk.weakSubjects]
          ..sort((a, b) => a.performanceScore.compareTo(b.performanceScore));

        final strongSubjects = [...risk.strongSubjects]
          ..sort((a, b) => b.performanceScore.compareTo(a.performanceScore));

        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPaddingH),
            children: [
              // High Risk Banner
              if (risk.riskLevel == "HIGH") ...[
                const AlertBanner(
                  type: BannerType.error,
                  message:
                      "You are currently at high academic risk. Focus on the subjects below.",
                ),
                const SizedBox(height: AppSizes.md),
              ],

              // Overall Risk
              RiskCard(risk: risk),

              // No subject-wise analysis available
              if (weakSubjects.isEmpty && strongSubjects.isEmpty) ...[
                const SizedBox(height: AppSizes.xl),

                const EmptyDashboardWidget(
                  title: "No Subject Analysis",
                  message:
                      "Subject-wise performance analysis is not available yet.",
                ),
              ],

              // Needs Attention
              if (weakSubjects.isNotEmpty) ...[
                const SizedBox(height: AppSizes.xl),

                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: AppSizes.sm),
                  child: Text(
                    "Needs Attention",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                ...weakSubjects.map(
                  (subject) => SubjectPerformanceCard(subject: subject),
                ),
              ],

              // Keep It Up
              if (strongSubjects.isNotEmpty) ...[
                const SizedBox(height: AppSizes.xl),

                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: AppSizes.sm),
                  child: Text(
                    "Keep It Up",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),

                ...strongSubjects.map(
                  (subject) => SubjectPerformanceCard(subject: subject),
                ),
              ],

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    if (_isOwnDashboard) {
      return AppScaffold(
        title: "Risk Details",
        navItems: StudentNavItems.items,
        currentRoute: AppRoutes.student, //student
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Risk Details"), centerTitle: false),
      body: body,
    );
  }
}
