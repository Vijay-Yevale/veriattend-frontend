import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/utils/time_format.dart';
import 'package:veriattend_app/core/widgets/info_row.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class TimetableSlotCard extends StatelessWidget {
  final String startTime;
  final String endTime;

  final String subjectName;

  final String infoText;

  final IconData infoIcon;

  final String room;

  final bool canManage;

  final bool isLive;

  final bool isCompleted;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TimetableSlotCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.infoText,
    required this.infoIcon,
    required this.room,
    this.canManage = false,
    this.isLive = false,
    this.isCompleted = false,
    this.onEdit,
    this.onDelete,
  });

  Widget _chip({
    required String label,
    required Color color,
    bool dot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSizes.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildTrailing() {
    Widget? statusChip;

    if (isLive) {
      statusChip = _chip(label: 'CURRENT', color: AppColors.primary, dot: true);
    }

    if (statusChip == null && !canManage) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (statusChip != null) ...[
          statusChip,
          const SizedBox(width: AppSizes.xs),
        ],
        if (canManage)
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: AppSizes.iconSm),
                    SizedBox(width: AppSizes.sm),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: AppSizes.iconSm,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final card = SectionCard(
      title: '${formatTime12Hr(startTime)} - ${formatTime12Hr(endTime)}',
      showArrow: false,
      trailing: _buildTrailing(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subjectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          InfoRow(icon: infoIcon, value: infoText),

          const SizedBox(height: AppSizes.sm),

          InfoRow(icon: Icons.location_on_outlined, value: room),

          if (isCompleted) ...[
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'Completed',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (isLive) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colorScheme.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(
                alpha: theme.brightness == Brightness.dark ? .20 : .12,
              ),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: card,
      );
    }

    return card;
  }
}
