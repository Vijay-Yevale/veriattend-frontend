import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/utils/time_format.dart';
import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';

class ActiveLectureBanner extends StatelessWidget {
  final TimetableSlotModel? activeSlot;

  final String? infoText;
  final IconData infoIcon;

  const ActiveLectureBanner({
    super.key,
    required this.activeSlot,
    this.infoText,
    this.infoIcon = Icons.person_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final slot = activeSlot;

    if (slot == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final resolvedInfoText = infoText ?? slot.teacher.userName;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.primary.withValues(alpha: 0.045),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.35),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.sm),

              Text(
                'CURRENT PERIOD',
                style: AppTextStyles.labelMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  '${formatTime12Hr(slot.startTime)} - '
                  '${formatTime12Hr(slot.endTime)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          Text(
            slot.subject.subjectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          Wrap(
            spacing: AppSizes.lg,
            runSpacing: AppSizes.sm,
            children: [
              _InfoItem(icon: infoIcon, text: resolvedInfoText),
              _InfoItem(icon: Icons.meeting_room_outlined, text: slot.room),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: colorScheme.onSurfaceVariant),

        const SizedBox(width: AppSizes.xs),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
