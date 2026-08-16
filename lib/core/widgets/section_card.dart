// lib/core/widgets/section_card.dart

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool showArrow;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
    this.trailing,
    this.padding,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusLg);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: .05),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withValues(alpha: .06),
        highlightColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(AppSizes.cardPadding),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: .8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (onTap != null && showArrow)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppSizes.iconSm,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
