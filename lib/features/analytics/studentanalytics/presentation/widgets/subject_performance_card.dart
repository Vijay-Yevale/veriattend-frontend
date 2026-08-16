import 'package:flutter/material.dart';
import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/risk_model.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class SubjectPerformanceCard extends StatelessWidget {
  final RiskSubjectModel subject;

  const SubjectPerformanceCard({super.key, required this.subject});

  Color get _color {
    switch (subject.riskLevel.toUpperCase()) {
      case 'HIGH':
        return AppColors.error;
      case 'MEDIUM':
        return AppColors.warning;
      case 'LOW':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progress = (subject.performanceScore / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: SectionCard(
        title: subject.subjectName,
        showArrow: false,
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Text(
            '${subject.performanceScore.toStringAsFixed(1)}%',
            style: AppTextStyles.titleMedium.copyWith(
              color: _color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject.subjectCode,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  subject.riskLevel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: colorScheme.outline.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.55 : 0.45,
                ),
                valueColor: AlwaysStoppedAnimation(_color),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${subject.performanceScore.toStringAsFixed(1)} / 100',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
