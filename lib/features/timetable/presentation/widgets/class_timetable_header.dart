import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/info_row.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

class ClassTimetableHeader extends StatelessWidget {
  final String className;
  final String classTeacherName;
  final int semester;

  const ClassTimetableHeader({
    super.key,
    required this.className,
    required this.classTeacherName,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SectionCard(
      title: className,
      showArrow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(
                    Icons.groups_outlined,
                    color: Colors.white,
                    size: AppSizes.iconMd,
                  ),
                ),

                const SizedBox(width: AppSizes.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Timetable',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: AppSizes.xs),

                      Text(
                        className,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          Text(
            'Class Details',
            style: AppTextStyles.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Class Teacher',
            value: classTeacherName,
          ),

          const SizedBox(height: AppSizes.md),

          InfoRow(
            icon: Icons.school_outlined,
            label: 'Semester',
            value: 'Semester $semester',
          ),
        ],
      ),
    );
  }
}
