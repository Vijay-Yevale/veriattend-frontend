import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';

enum DashboardFilterType { all, highRisk, mediumRisk, lowRisk, defaulters }

class DashboardFilterChips extends StatelessWidget {
  final DashboardFilterType selectedFilter;
  final ValueChanged<DashboardFilterType> onSelected;

  final int highRiskCount;
  final int mediumRiskCount;
  final int lowRiskCount;
  final int defaultersCount;

  const DashboardFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    required this.defaultersCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            label: 'All',
            type: DashboardFilterType.all,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.sm),
          _chip(
            label: 'High ($highRiskCount)',
            type: DashboardFilterType.highRisk,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSizes.sm),
          _chip(
            label: 'Medium ($mediumRiskCount)',
            type: DashboardFilterType.mediumRisk,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSizes.sm),
          _chip(
            label: 'Low ($lowRiskCount)',
            type: DashboardFilterType.lowRisk,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSizes.sm),
          _chip(
            label: 'Defaulters ($defaultersCount)',
            type: DashboardFilterType.defaulters,
            color: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required DashboardFilterType type,
    required Color color,
  }) {
    final selected = selectedFilter == type;

    return FilterChip(
      selected: selected,
      onSelected: (_) => onSelected(type),
      showCheckmark: false,
      label: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withValues(alpha: .08),
      selectedColor: color,
      side: BorderSide(color: color.withValues(alpha: .25)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
    );
  }
}
