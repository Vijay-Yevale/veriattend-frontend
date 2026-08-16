// lib/core/widgets/form_section.dart

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class FormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;

  const FormSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
                  const SizedBox(width: AppSizes.sm),
                ],

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),

                      if (subtitle != null) ...[
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            child,
          ],
        ),
      ),
    );
  }
}
