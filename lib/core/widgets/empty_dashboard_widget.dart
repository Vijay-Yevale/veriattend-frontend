import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class EmptyDashboardWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const EmptyDashboardWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.analytics_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: AppSizes.cardElevation,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: AppSizes.iconXl,
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: AppSizes.sm),

            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            Text(
              "Pull down to refresh",
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
