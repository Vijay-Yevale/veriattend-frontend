import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class StudentAnalyticsCard extends StatelessWidget {
  final int totalStudents;
  final VoidCallback? onTap;

  const StudentAnalyticsCard({
    super.key,
    required this.totalStudents,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: "Student Analytics",
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: AppSizes.iconSm,
        color: colorScheme.onSurfaceVariant,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.groups_rounded,
            color: AppColors.primary,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$totalStudents Students",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  "Search, filter and view student analytics",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
