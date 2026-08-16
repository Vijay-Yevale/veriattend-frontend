// lib/core/widgets/warning_banner.dart

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

/// Banner styles
enum BannerType { warning, error, success, info }

class AlertBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onTap;
  final String? actionLabel;

  const AlertBanner({
    super.key,
    required this.message,
    this.type = BannerType.warning,
    this.onTap,
    this.actionLabel,
  });

  Color get _color {
    switch (type) {
      case BannerType.warning:
        return AppColors.warning;
      case BannerType.error:
        return AppColors.error;
      case BannerType.success:
        return AppColors.success;
      case BannerType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (type) {
      case BannerType.warning:
        return Icons.warning_amber_rounded;
      case BannerType.error:
        return Icons.error_outline_rounded;
      case BannerType.success:
        return Icons.check_circle_outline_rounded;
      case BannerType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSizes.radiusSm);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.08),
            borderRadius: borderRadius,
            border: Border.all(color: _color.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: Row(
              children: [
                // ─── Icon ─────────────────────────────
                Icon(_icon, color: _color, size: AppSizes.iconSm),

                const SizedBox(width: AppSizes.sm),

                // ─── Message ──────────────────────────
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodySmall.copyWith(color: _color),
                  ),
                ),

                // ─── Optional Action Label ────────────
                if (actionLabel != null && onTap != null) ...[
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    actionLabel!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: _color,
                    ),
                  ),
                ],

                // ─── Chevron if tappable ──────────────
                if (onTap != null && actionLabel == null) ...[
                  const SizedBox(width: AppSizes.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _color,
                    size: AppSizes.iconSm,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
