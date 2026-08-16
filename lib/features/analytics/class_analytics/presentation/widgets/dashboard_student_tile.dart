import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/risk_badge.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_student_model.dart';

class DashboardStudentTile extends StatelessWidget {
  final DashboardStudentModel student;
  final VoidCallback? onTap;

  const DashboardStudentTile({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: SectionCard(
        title: student.userName,
        onTap: onTap,
        trailing: RiskBadge(
          riskLevel: student.riskLevel,
          size: RiskBadgeSize.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PRN : ${student.prn}",
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    icon: Icons.fact_check_outlined,
                    label: "Attendance",
                    value:
                        student.attendancePercentage?.toStringAsFixed(1) != null
                        ? "${student.attendancePercentage!.toStringAsFixed(1)}%"
                        : "--",
                    color: AppColors.info,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    icon: Icons.trending_up_rounded,
                    label: "Performance",
                    value: student.performanceScore?.toStringAsFixed(1) ?? "--",
                    color: AppColors.success,
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

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppSizes.iconSm),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
