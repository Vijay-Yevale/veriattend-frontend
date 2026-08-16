import 'package:flutter/material.dart';
import 'package:veriattend_app/core/constants/api_constants.dart';
import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/subject_mark_model.dart';
import 'package:veriattend_app/core/widgets/metric_progress.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class SubjectMarkCard extends StatelessWidget {
  final SubjectMarkModel subject;

  const SubjectMarkCard({super.key, required this.subject});

  bool get _hasAnyMarks =>
      subject.quizAverage != null ||
      subject.assignmentAverage != null ||
      subject.internalMarks != null;

  String _formatMark(double? value, double max) {
    if (value == null) return 'Pending';

    final display = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return '$display / ${max.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: SectionCard(
        title: subject.subjectName,
        showArrow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject.subjectCode,
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (!_hasAnyMarks) ...[
              const SizedBox(height: AppSizes.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.lg,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.50,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pending_actions_outlined,
                        color: colorScheme.primary,
                        size: AppSizes.iconMd,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Marks have not been published yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSizes.md),
              if (subject.quizAverage != null) ...[
                MetricProgress(
                  title: 'Quiz Average',
                  value: _formatMark(subject.quizAverage, ApiConstants.quizMax),
                  progress: subject.quizAverage! / ApiConstants.quizMax,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.md),
              ],
              if (subject.assignmentAverage != null) ...[
                MetricProgress(
                  title: 'Assignment Average',
                  value: _formatMark(
                    subject.assignmentAverage,
                    ApiConstants.assignmentMax,
                  ),
                  progress:
                      subject.assignmentAverage! / ApiConstants.assignmentMax,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSizes.md),
              ],
              if (subject.internalMarks != null)
                MetricProgress(
                  title: 'Internal',
                  value: _formatMark(
                    subject.internalMarks,
                    ApiConstants.internalMax,
                  ),
                  progress: subject.internalMarks! / ApiConstants.internalMax,
                  color: AppColors.success,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
