import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';

class TeacherClassListItem extends StatelessWidget {
  final String className;
  final bool isClassTeacher;
  final List<String> subjectNames;
  final VoidCallback onTap;

  const TeacherClassListItem({
    super.key,
    required this.className,
    required this.isClassTeacher,
    required this.subjectNames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final subtitle = subjectNames.isEmpty
        ? 'No subject assigned'
        : subjectNames.join('  •  ');

    final radius = BorderRadius.circular(AppSizes.radiusMd);

    final cardBackground = isClassTeacher
        ? colorScheme.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.10
                : 0.045,
          )
        : colorScheme.surfaceContainerHighest;

    final borderColor = isClassTeacher
        ? colorScheme.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.40
                : 0.30,
          )
        : colorScheme.outline;

    return Material(
      color: cardBackground,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isClassTeacher)
                    Container(width: AppSizes.xs, color: colorScheme.primary),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.cardPadding),
                      child: Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: isClassTeacher
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                            child: Icon(
                              isClassTeacher
                                  ? Icons.star_rounded
                                  : Icons.groups_outlined,
                              color: isClassTeacher
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary,
                              size: AppSizes.iconMd,
                            ),
                          ),

                          const SizedBox(width: AppSizes.md),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        className,
                                        style: AppTextStyles.titleLarge
                                            .copyWith(
                                              color: colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    if (isClassTeacher) ...[
                                      const SizedBox(width: AppSizes.xs),
                                      const _ClassTeacherBadge(),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: AppSizes.xs),

                                Text(
                                  subtitle,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: AppSizes.sm),

                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.04,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: AppSizes.iconSm,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassTeacherBadge extends StatelessWidget {
  const _ClassTeacherBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        'Class Teacher',
        style: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
