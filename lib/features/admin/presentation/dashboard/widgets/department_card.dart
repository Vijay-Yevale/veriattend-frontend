import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/department_model.dart';

class DepartmentCard extends StatelessWidget {
  final DepartmentModel department;
  final VoidCallback? onTap;

  const DepartmentCard({super.key, required this.department, this.onTap});

  IconData _getDepartmentIcon(String code) {
    switch (code.toUpperCase()) {
      case 'CS':
        return Icons.computer_rounded;
      case 'ME':
        return Icons.settings_rounded;
      case 'CV':
        return Icons.foundation_rounded;
      case 'IT':
        return Icons.memory_rounded;
      case 'AI':
        return Icons.smart_toy_rounded;
      case 'ENTC':
        return Icons.electrical_services_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _getDepartmentColor(String code) {
    switch (code.toUpperCase()) {
      case 'CS':
        return AppColors.primary;
      case 'ME':
        return AppColors.warning;
      case 'CV':
        return AppColors.success;
      case 'IT':
        return Colors.indigo;
      case 'AI':
        return Colors.deepPurple;
      case 'ENTC':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDepartmentColor(department.code);
    final icon = _getDepartmentIcon(department.code);
    final colorScheme = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(AppSizes.radiusLg);

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: .05),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: colorScheme.primary.withValues(alpha: .06),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: .8),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: AppSizes.iconMd),
              ),

              const SizedBox(width: AppSizes.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${department.code}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
