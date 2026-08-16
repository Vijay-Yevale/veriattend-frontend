import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/risk_model.dart';
import 'package:veriattend_app/core/widgets/metric_progress.dart';
import 'package:veriattend_app/core/widgets/risk_badge.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class RiskCard extends StatelessWidget {
  final RiskModel risk;
  final VoidCallback? onTap;

  const RiskCard({super.key, required this.risk, this.onTap});

  String get _updatedText {
    if (risk.lastUpdated == null) {
      return 'Not Available';
    }

    return timeago.format(risk.lastUpdated!);
  }

  Color get _progressColor {
    switch (risk.riskLevel?.toUpperCase()) {
      case 'LOW':
        return AppColors.success;

      case 'MEDIUM':
        return AppColors.warning;

      case 'HIGH':
        return AppColors.error;

      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final score = risk.performanceScore ?? 0;

    return SectionCard(
      title: 'Risk Analysis',
      onTap: onTap,
      trailing: RiskBadge(riskLevel: risk.riskLevel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricProgress(
            title: 'Performance Score',
            value: '${score.toStringAsFixed(1)}/100',
            progress: score / 100,
            color: _progressColor,
          ),

          const SizedBox(height: AppSizes.md),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.55 : 0.50,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: AppSizes.iconSm + 2,
                  color: colorScheme.onSurfaceVariant,
                ),

                const SizedBox(width: AppSizes.sm),

                Expanded(
                  child: Text(
                    'Updated $_updatedText',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
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
