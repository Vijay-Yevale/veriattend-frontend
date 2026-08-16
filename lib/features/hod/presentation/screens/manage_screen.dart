import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/quick_action_card.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Manage',
      navItems: HodNavItems.items,
      currentRoute: AppRoutes.hodmanage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
          vertical: AppSizes.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              title: 'Management',
              child: Column(
                children: [
                  QuickActionCard(
                    icon: Icons.person_outline,
                    title: 'Teachers',
                    subtitle: 'Create and manage teachers',
                    onTap: () => context.push(AppRoutes.hodTeachers),
                  ),

                  const SizedBox(height: AppSizes.md),

                  QuickActionCard(
                    icon: Icons.class_outlined,
                    title: 'Classes',
                    subtitle: 'Create and manage classes',
                    onTap: () => context.push(AppRoutes.hodClasses),
                  ),

                  const SizedBox(height: AppSizes.md),

                  QuickActionCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Subjects',
                    subtitle: 'Create and manage subjects',
                    onTap: () => context.push(AppRoutes.hodSubjects),
                  ),

                  const SizedBox(height: AppSizes.md),

                  QuickActionCard(
                    icon: Icons.assignment_ind_outlined,
                    title: 'Assign Teacher',
                    subtitle: 'Assign teachers to subjects',
                    onTap: () => context.push(AppRoutes.hodAssignTeacher),
                  ),

                  const SizedBox(height: AppSizes.md),

                  QuickActionCard(
                    icon: Icons.groups_outlined,
                    title: 'Assign Students',
                    subtitle: 'Assign students to classes',
                    onTap: () => context.push(AppRoutes.hodAssignStudents),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xxl),

            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      'Use the management options above to configure teachers, classes, subjects, and assignments for your department.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
