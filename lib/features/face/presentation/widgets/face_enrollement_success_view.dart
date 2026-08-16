import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';

class FaceEnrollmentSuccessView extends StatelessWidget {
  final VoidCallback onContinue;

  const FaceEnrollmentSuccessView({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(AppSizes.sm),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: AppSizes.iconXl,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            Text(
              'Face Registered',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.sm),

            Text(
              'Your face has been registered for secure attendance.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: AppSizes.iconSm + 2,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Flexible(
                    child: Text(
                      'Face verification is ready to use.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            AppButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
