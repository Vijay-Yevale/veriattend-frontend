import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

enum RiskBadgeSize { small, medium, large }

class RiskBadge extends StatelessWidget {
  final String? riskLevel;
  final RiskBadgeSize size;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.size = RiskBadgeSize.medium,
  });

  Color _colorFor(BuildContext context) {
    switch (riskLevel?.toUpperCase()) {
      case 'LOW':
        return AppColors.riskLow;
      case 'MEDIUM':
        return AppColors.riskMedium;
      case 'HIGH':
        return AppColors.riskHigh;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData get _icon {
    switch (riskLevel?.toUpperCase()) {
      case 'LOW':
        return Icons.check_circle_rounded;

      case 'MEDIUM':
        return Icons.warning_amber_rounded;

      case 'HIGH':
        return Icons.error_rounded;

      default:
        return Icons.help_outline_rounded;
    }
  }

  String get _label {
    switch (riskLevel?.toUpperCase()) {
      case 'LOW':
        return 'LOW RISK';

      case 'MEDIUM':
        return 'MEDIUM RISK';

      case 'HIGH':
        return 'HIGH RISK';

      default:
        return 'NOT AVAILABLE';
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case RiskBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

      case RiskBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);

      case RiskBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
    }
  }

  double get _iconSize {
    switch (size) {
      case RiskBadgeSize.small:
        return 16;

      case RiskBadgeSize.medium:
        return 18;

      case RiskBadgeSize.large:
        return 22;
    }
  }

  TextStyle _textStyleFor(Color color) {
    switch (size) {
      case RiskBadgeSize.small:
        return AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        );

      case RiskBadgeSize.medium:
        return AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        );

      case RiskBadgeSize.large:
        return AppTextStyles.labelLarge.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: _padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: color, size: _iconSize),

          const SizedBox(width: AppSizes.xs),

          Text(_label, style: _textStyleFor(color)),
        ],
      ),
    );
  }
}
