import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/academic_summary_model.dart';
import 'package:veriattend_app/core/widgets/circular_metric.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class AcademicCard extends StatelessWidget {
  final AcademicSummaryModel? academic;
  final VoidCallback? onTap;

  const AcademicCard({super.key, required this.academic, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (academic == null) {
      return SectionCard(
        title: 'Academic Performance',
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: AppSizes.iconLg,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'No academic records available yet.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget metric({
      required String label,
      required double? value,
      required double max,
      required Color color,
      required IconData icon,
    }) {
      final hasValue = value != null;

      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppSizes.iconSm, color: color),
            ),

            const SizedBox(height: AppSizes.xs),

            SizedBox(
              width: double.infinity,
              height: 92,
              child: FittedBox(
                fit: BoxFit.contain,
                child: CircularMetric(
                  progress: hasValue ? (value / max).clamp(0.0, 1.0) : 0.0,
                  value: hasValue ? value.toStringAsFixed(1) : '--',
                  subtitle: '/${max.toInt()}',
                  label: label,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      title: 'Academic Performance',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.xs,
              right: AppSizes.xs,
              bottom: AppSizes.md,
            ),
            child: Text(
              'Your average academic scores',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.55 : 0.45,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                metric(
                  label: 'Quiz',
                  value: academic!.quizAverage,
                  max: 10,
                  color: AppColors.info,
                  icon: Icons.quiz_outlined,
                ),

                Container(
                  width: 1,
                  height: 100,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: AppSizes.sm,
                  ),
                  color: colorScheme.outline.withValues(alpha: 0.45),
                ),

                metric(
                  label: 'Assignment',
                  value: academic!.assignmentAverage,
                  max: 25,
                  color: AppColors.warning,
                  icon: Icons.assignment_outlined,
                ),

                Container(
                  width: 1,
                  height: 100,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: AppSizes.sm,
                  ),
                  color: colorScheme.outline.withValues(alpha: 0.45),
                ),

                metric(
                  label: 'Internal',
                  value: academic!.internalMarks,
                  max: 30,
                  color: AppColors.success,
                  icon: Icons.school_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: AppSizes.iconSm,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: Text(
                  'Scores are shown against the maximum marks for each category.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
