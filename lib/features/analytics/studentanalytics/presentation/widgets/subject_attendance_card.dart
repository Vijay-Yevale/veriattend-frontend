import 'package:flutter/material.dart';
import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/subject_wise_model.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class SubjectAttendanceCard extends StatelessWidget {
  final SubjectWiseModel subject;

  const SubjectAttendanceCard({super.key, required this.subject});

  Color get _attendanceColor {
    if (subject.attendancePercentage >= 75) {
      return AppColors.attendanceGood;
    }

    if (subject.attendancePercentage >= 60) {
      return AppColors.attendanceWarning;
    }

    return AppColors.attendanceDanger;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progress = (subject.attendancePercentage / 100).clamp(0.0, 1.0);

    final isRequirementMet = subject.classesNeededFor75 <= 0;

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
            color: _attendanceColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Text(
            '${subject.attendancePercentage.toStringAsFixed(1)}%',
            style: AppTextStyles.titleMedium.copyWith(
              color: _attendanceColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject.subjectCode,
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
                valueColor: AlwaysStoppedAnimation(_attendanceColor),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _attendanceColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: _attendanceColor,
                    size: AppSizes.iconSm + 2,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    '${subject.totalAttended} of '
                    '${subject.totalClasses} classes attended',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isRequirementMet
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color:
                      (isRequirementMet ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isRequirementMet
                        ? Icons.verified_rounded
                        : Icons.warning_amber_rounded,
                    color: isRequirementMet
                        ? AppColors.success
                        : AppColors.warning,
                    size: AppSizes.iconSm + 2,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      isRequirementMet
                          ? 'Attendance requirement met'
                          : 'Attend ${subject.classesNeededFor75} '
                                '${subject.classesNeededFor75 == 1 ? 'more class' : 'more classes'} '
                                'to reach 75% attendance.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isRequirementMet
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
