import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

enum StatTileSize { small, medium, large }

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final StatTileSize size;
  final IconData? icon;
  final double? valueWidth;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.size = StatTileSize.medium,
    this.icon,
    this.valueWidth,
  });

  TextStyle get _valueStyle {
    switch (size) {
      case StatTileSize.small:
        return AppTextStyles.headlineSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        );

      case StatTileSize.medium:
        return AppTextStyles.displayMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        );

      case StatTileSize.large:
        return AppTextStyles.displayMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        );
    }
  }

  double get _iconSize {
    switch (size) {
      case StatTileSize.small:
        return 18;

      case StatTileSize.medium:
        return 22;

      case StatTileSize.large:
        return 26;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: _iconSize),
          const SizedBox(height: AppSizes.xs),
        ],

        SizedBox(
          width: valueWidth,
          child: Text(value, style: _valueStyle, textAlign: TextAlign.center),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class StatTileRow extends StatelessWidget {
  final List<StatTile> tiles;

  const StatTileRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(tiles.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == tiles.length - 1 ? 0 : AppSizes.sm,
            ),
            child: tiles[index],
          ),
        );
      }),
    );
  }
}

class StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const StatMiniCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 4),

              Text(
                subtitle!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 8),

            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
