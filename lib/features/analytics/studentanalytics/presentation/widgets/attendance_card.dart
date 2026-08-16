import 'package:flutter/material.dart';
import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/attendance_model.dart';
import 'package:veriattend_app/core/widgets/attendance_indicator.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/stat_tile.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;
  final VoidCallback? onTap;

  const AttendanceCard({super.key, required this.attendance, this.onTap});

  Color get _color {
    if (attendance.attendancePercentage >= 75) {
      return AppColors.attendanceGood;
    }

    if (attendance.attendancePercentage >= 60) {
      return AppColors.attendanceWarning;
    }

    return AppColors.attendanceDanger;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final percentage = attendance.attendancePercentage;

    return SectionCard(
      title: 'Attendance',
      onTap: onTap,
      child: Column(
        children: [
          // Main attendance indicator
          AttendanceIndicator(percentage: percentage, color: _color),

          const SizedBox(height: AppSizes.lg),

          // Attendance statistics
          StatTileRow(
            tiles: [
              StatTile(
                label: 'Present',
                value: attendance.totalAttended.toString(),
                color: AppColors.success,
                icon: Icons.check_circle_outline_rounded,
              ),
              StatTile(
                label: 'Absent',
                value: attendance.classesMissed.toString(),
                color: AppColors.error,
                icon: Icons.cancel_outlined,
              ),
              StatTile(
                label: 'Total',
                value: attendance.totalClasses.toString(),
                color: AppColors.primary,
                icon: Icons.menu_book_outlined,
              ),
            ],
          ),

          if (attendance.classesNeededFor75 > 0) ...[
            const SizedBox(height: AppSizes.lg),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: AppSizes.iconSm + 2,
                      color: AppColors.warning,
                    ),
                  ),

                  const SizedBox(width: AppSizes.sm),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSizes.xs),
                      child: Text(
                        '${attendance.classesNeededFor75} more '
                        'classes needed to reach 75% attendance',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSizes.lg),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      size: AppSizes.iconSm + 2,
                      color: AppColors.success,
                    ),
                  ),

                  const SizedBox(width: AppSizes.sm),

                  Expanded(
                    child: Text(
                      'Attendance requirement met',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (colorScheme.brightness == Brightness.dark)
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
