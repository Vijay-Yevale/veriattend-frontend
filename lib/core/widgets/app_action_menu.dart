// lib/core/widgets/app_action_menu.dart

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class AppActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool enabled;

  const AppActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.enabled = true,
  });
}

class AppActionMenu extends StatelessWidget {
  final List<AppActionItem> actions;
  final IconData icon;
  final String tooltip;

  const AppActionMenu({
    super.key,
    required this.actions,
    this.icon = Icons.more_vert_rounded,
    this.tooltip = 'More actions',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final textColor = colorScheme.onSurface;
    final secondaryColor = colorScheme.onSurfaceVariant;
    final borderColor = colorScheme.outline;
    final surfaceColor = colorScheme.surface;

    return PopupMenuButton<AppActionItem>(
      tooltip: tooltip,
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: AppSizes.cardElevation,
      splashRadius: 22,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(color: borderColor),
      ),
      icon: Icon(icon, size: AppSizes.iconMd, color: secondaryColor),
      onSelected: (item) {
        if (item.enabled) {
          item.onTap();
        }
      },
      itemBuilder: (context) {
        return actions.map((action) {
          final actionColor = action.enabled
              ? (action.color ?? AppColors.primary)
              : secondaryColor;

          return PopupMenuItem<AppActionItem>(
            value: action,
            enabled: action.enabled,
            child: Opacity(
              opacity: action.enabled ? 1 : 0.55,
              child: Row(
                children: [
                  Icon(action.icon, size: AppSizes.iconSm, color: actionColor),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      action.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }
}
