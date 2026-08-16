// lib/core/widgets/attendance_indicator.dart

import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

class AttendanceIndicator extends StatelessWidget {
  final double percentage;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool animate;

  const AttendanceIndicator({
    super.key,
    required this.percentage,
    required this.color,
    this.size = 130,
    this.strokeWidth = 10,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (percentage / 100).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: animate ? 0 : progress, end: progress),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  backgroundColor: colorScheme.outline,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(value * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Attendance',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
