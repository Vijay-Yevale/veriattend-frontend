import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;

  final String? label;

  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.trim().isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),

        const SizedBox(width: AppSizes.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLabel) ...[
                Text(
                  label!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSizes.xs),
              ],

              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
