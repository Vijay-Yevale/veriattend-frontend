import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

import '../providers/manage_provider.dart';

class TeacherListWidget extends ConsumerWidget {
  const TeacherListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersProvider);

    return teachersAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xxl),
        child: AppLoader(),
      ),

      error: (error, stackTrace) => AppErrorWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(teachersProvider),
      ),

      data: (teachers) {
        if (teachers.isEmpty) {
          return const EmptyDashboardWidget(
            title: 'No Teachers Found',
            message: 'Create your first teacher account to get started.',
            icon: Icons.people_outline,
          );
        }

        final colorScheme = Theme.of(context).colorScheme;

        return SectionCard(
          title: 'Teachers',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      '${teachers.length} Teacher${teachers.length == 1 ? '' : 's'}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              Divider(
                color: colorScheme.outline.withValues(alpha: 0.25),
                height: 1,
              ),

              const SizedBox(height: AppSizes.sm),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teachers.length,
                separatorBuilder: (_, __) => Divider(
                  height: AppSizes.lg,
                  color: colorScheme.outline.withValues(alpha: 0.20),
                ),
                itemBuilder: (context, index) {
                  final teacher = teachers[index];

                  return Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: AppSizes.md),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: AppSizes.xs),

                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Expanded(
                                  child: Text(
                                    teacher.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppSizes.sm),

                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
