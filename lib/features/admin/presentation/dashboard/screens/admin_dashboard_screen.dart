import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/greeting_section.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/providers/department_provider.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/widgets/department_card.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentsProvider);
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : '';

    return AppScaffold(
      showAppBar: false,
      navItems: AdminNavItems.items,
      currentRoute: AppRoutes.admin,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
          vertical: AppSizes.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingSection(
              userName: userName,
              subtitle: 'Manage your departments efficiently',
            ),

            const SizedBox(height: AppSizes.lg),

            Text(
              'Departments',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppSizes.md),

            Expanded(
              child: departmentsAsync.when(
                loading: () => const AppLoader(),

                error: (error, stackTrace) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(departmentsProvider),
                ),

                data: (departments) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(departmentsProvider);
                    await ref.read(departmentsProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: departments.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.sm),
                    itemBuilder: (context, index) {
                      final department = departments[index];

                      return DepartmentCard(
                        department: department,
                        onTap: () {
                          context.push(
                            AppRoutes.departmentAnalytics(department.id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
