import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/risk_badge.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

import '../../domain/model/subject_risk_model.dart';

class SubjectRiskCard extends StatelessWidget {
  final SubjectRiskModel risk;

  const SubjectRiskCard({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Risk Assessment",
      showArrow: false,
      trailing: RiskBadge(riskLevel: risk.riskLevel, size: RiskBadgeSize.small),
      child: Row(
        children: [
          Expanded(
            child: _MetricTile(
              label: "Performance",
              value: risk.performanceScore.toStringAsFixed(1),
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: _MetricTile(
              label: "Risk Level",
              value: risk.riskLevel,
              color: _riskColor(risk.riskLevel),
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(String level) {
    switch (level) {
      case "LOW":
        return AppColors.success;
      case "MEDIUM":
        return AppColors.warning;
      case "HIGH":
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
