import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_class_model.dart';

class DepartmentClassCard extends StatelessWidget {
  final DepartmentClassModel departmentClass;
  final VoidCallback? onTap;

  const DepartmentClassCard({
    super.key,
    required this.departmentClass,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppSizes.radiusLg);

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: .05),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withValues(alpha: .06),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.cardPadding),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: .8),
            ),
          ),
          child: Row(
            children: [
              /// Class Avatar
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),

              const SizedBox(width: AppSizes.md),

              /// Class Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departmentClass.className,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: AppSizes.xs),

                    Text(
                      "Class Teacher",
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      departmentClass.classTeacher?.userName ?? "Not Assigned",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: departmentClass.classTeacher == null
                            ? AppColors.warning
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.sm),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppSizes.iconSm,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
