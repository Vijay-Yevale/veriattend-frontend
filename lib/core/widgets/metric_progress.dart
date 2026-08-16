// lib/core/widgets/metric_progress.dart

import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

class MetricProgress extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;
  final double height;
  final bool animate;

  const MetricProgress({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
    this.height = 8,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: animate ? 0 : safeProgress, end: safeProgress),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: LinearProgressIndicator(
                value: value,
                minHeight: height,
                backgroundColor: colorScheme.outline,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            );
          },
        ),
      ],
    );
  }
}
