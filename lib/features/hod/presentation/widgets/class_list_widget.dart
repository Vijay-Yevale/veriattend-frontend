import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/class_model.dart';

import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_dashboard_widget.dart';
import '../../../../core/widgets/section_card.dart';
import '../providers/manage_provider.dart';

class ClassListWidget extends ConsumerWidget {
  const ClassListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesProvider);

    return SectionCard(
      title: 'Classes',
      child: classesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: AppLoader(),
        ),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(classesProvider),
        ),
        data: (classes) {
          if (classes.isEmpty) {
            return const EmptyDashboardWidget(
              title: 'No Classes',
              message: 'No classes have been created for your department yet.',
              icon: Icons.apartment_outlined,
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: classes.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              return _ClassTile(classModel: classes[index]);
            },
          );
        },
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  final ClassModel classModel;

  const _ClassTile({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final teacherName = classModel.classTeacher?.userName ?? 'Not Assigned';

    final isAssigned = classModel.classTeacher != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.iconXl,
            height: AppSizes.iconXl,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              Icons.apartment_outlined,
              color: colorScheme.primary,
              size: AppSizes.iconMd,
            ),
          ),

          const SizedBox(width: AppSizes.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classModel.className,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppSizes.xs),

                Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: AppSizes.iconSm,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'Semester ${classModel.semester}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xs),

                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: AppSizes.iconSm,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Expanded(
                      child: Text(
                        teacherName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.sm),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: (isAssigned ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              isAssigned ? 'Assigned' : 'Unassigned',
              style: AppTextStyles.labelSmall.copyWith(
                color: isAssigned ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
