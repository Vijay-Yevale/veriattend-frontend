import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/greeting_section.dart';
import 'package:veriattend_app/features/analytics/department_analytics/presentation/widgets/dashboard_summary_card.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:veriattend_app/features/analytics/department_analytics/presentation/providers/department_analytics_provider.dart';
import 'package:veriattend_app/features/analytics/department_analytics/presentation/widgets/department_class_card.dart';

class DepartmentAnalyticsScreen extends ConsumerStatefulWidget {
  final String? departmentId;

  const DepartmentAnalyticsScreen({super.key, this.departmentId});

  @override
  ConsumerState<DepartmentAnalyticsScreen> createState() =>
      _DepartmentAnalyticsScreenState();
}

class _DepartmentAnalyticsScreenState
    extends ConsumerState<DepartmentAnalyticsScreen>
    with WidgetsBindingObserver {
  bool get _isOwnDepartment => widget.departmentId == null;

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
      ref.invalidate(departmentAnalyticsProvider(widget.departmentId));
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(departmentAnalyticsProvider(widget.departmentId));
    await ref.read(departmentAnalyticsProvider(widget.departmentId).future);
  }

  void _goToClassDashboard(String classId) {
    context.push(AppRoutes.classDashboard(classId));
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(
      departmentAnalyticsProvider(widget.departmentId),
    );

    Widget? greetingWidget;

    if (_isOwnDepartment) {
      final authState = ref.watch(authProvider);

      final hodName = switch (authState) {
        AuthAuthenticated(user: final user) => user.userName,
        _ => "HOD",
      };

      greetingWidget = GreetingSection(
        userName: hodName,
        subtitle: "Monitor classes and academic performance",
      );
    }

    final body = dashboard.when(
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

      error: (error, _) => Column(
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
              message: error.toString(),
              onRetry: () {
                ref.invalidate(
                  departmentAnalyticsProvider(widget.departmentId),
                );
              },
            ),
          ),
        ],
      ),

      data: (data) {
        final noClasses = data.classes.isEmpty;

        if (noClasses) {
          final availableHeight =
              MediaQuery.of(context).size.height -
              kToolbarHeight -
              (_isOwnDepartment ? kBottomNavigationBarHeight : 0);

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
                    alignment: Alignment(0, -.35),
                    child: EmptyDashboardWidget(
                      title: "No classes available",
                      message:
                          "Classes will appear here once they are created for this department.",
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
              DepartmentSummaryCard(summary: data.summary),
              const SizedBox(height: AppSizes.xl),
              Text(
                "Classes",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.md),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.classes.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.md),
                itemBuilder: (context, index) {
                  final departmentClass = data.classes[index];

                  return DepartmentClassCard(
                    departmentClass: departmentClass,
                    onTap: () => _goToClassDashboard(departmentClass.classId),
                  );
                },
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    if (_isOwnDepartment) {
      return AppScaffold(
        title: dashboard.asData?.value.departmentName ?? "Department",
        navItems: HodNavItems.items,
        currentRoute: AppRoutes.hod,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(dashboard.asData?.value.departmentName ?? "Department"),
        centerTitle: false,
      ),
      body: body,
    );
  }
}
