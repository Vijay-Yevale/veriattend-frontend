import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/stat_tile.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_summary_model.dart';

class DashboardSummaryCard extends StatelessWidget {
  final DashboardSummaryModel summary;

  const DashboardSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Dashboard Summary',
      showArrow: false,
      child: Column(
        children: [
          StatTileRow(
            tiles: [
              StatTile(
                label: 'Students',
                value: summary.totalStudents.toString(),
                color: AppColors.primary,
                icon: Icons.groups_rounded,
              ),
              StatTile(
                label: 'Attendance',
                value: '${summary.averageAttendance.toStringAsFixed(1)}%',
                color: AppColors.info,
                icon: Icons.fact_check_rounded,
              ),
              StatTile(
                label: 'Performance',
                value: summary.averagePerformance.toStringAsFixed(1),
                color: AppColors.success,
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          const Divider(),
          const SizedBox(height: AppSizes.lg),
          StatTileRow(
            tiles: [
              StatTile(
                label: 'High',
                value: summary.highRiskCount.toString(),
                color: AppColors.error,
                icon: Icons.error_rounded,
              ),
              StatTile(
                label: 'Medium',
                value: summary.mediumRiskCount.toString(),
                color: AppColors.warning,
                icon: Icons.warning_amber_rounded,
              ),
              StatTile(
                label: 'Low',
                value: summary.lowRiskCount.toString(),
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              ),
              StatTile(
                label: 'Defaulters',
                value: summary.defaultersCount.toString(),
                color: AppColors.primary,
                icon: Icons.person_off_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
