import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/widgets/department_form.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/widgets/hod_form.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/greeting_section.dart';
import 'package:veriattend_app/core/widgets/quick_action_card.dart';

import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

class AdminManageScreen extends ConsumerStatefulWidget {
  const AdminManageScreen({super.key});

  @override
  ConsumerState<AdminManageScreen> createState() => _AdminManageScreenState();
}

enum AdminManageAction { department, hod }

class _AdminManageScreenState extends ConsumerState<AdminManageScreen> {
  AdminManageAction? _selectedAction;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : 'User';

    return AppScaffold(
      showAppBar: false,
      navItems: AdminNavItems.items,
      currentRoute: AppRoutes.adminManage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
          vertical: AppSizes.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingSection(
              userName: userName,
              subtitle: 'Manage departments and Head of Department accounts.',
            ),

            const SizedBox(height: AppSizes.lg),

            Text(
              'Quick Actions',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppSizes.md),

            QuickActionCard(
              title: 'Create Department',
              subtitle: 'Add a new department to the institute.',
              icon: Icons.apartment_outlined,
              selected: _selectedAction == AdminManageAction.department,
              onTap: () {
                setState(() {
                  _selectedAction = AdminManageAction.department;
                });
              },
            ),

            const SizedBox(height: AppSizes.md),

            QuickActionCard(
              title: 'Create HOD Account',
              subtitle: 'Assign a Head of Department.',
              icon: Icons.person_add_alt_1_outlined,
              selected: _selectedAction == AdminManageAction.hod,
              onTap: () {
                setState(() {
                  _selectedAction = AdminManageAction.hod;
                });
              },
            ),

            const SizedBox(height: AppSizes.xl),

            if (_selectedAction == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.xxl,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: colorScheme.primary,
                          size: AppSizes.iconXl,
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      Text(
                        'Select an Action',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: AppSizes.sm),

                      Text(
                        'Choose one of the quick actions above to start managing departments or HOD accounts.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_selectedAction == AdminManageAction.department)
              DepartmentFormWidget(
                onCompleted: () {
                  setState(() {
                    _selectedAction = null;
                  });
                },
              ),

            if (_selectedAction == AdminManageAction.hod)
              HodFormWidget(
                onCompleted: () {
                  setState(() {
                    _selectedAction = null;
                  });
                },
              ),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
