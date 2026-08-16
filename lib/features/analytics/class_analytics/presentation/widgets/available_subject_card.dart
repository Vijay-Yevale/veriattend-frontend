import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/available_subject_model.dart';

class AvailableSubjectCard extends StatelessWidget {
  final AvailableSubjectModel subject;
  final VoidCallback? onTap;

  const AvailableSubjectCard({super.key, required this.subject, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: SectionCard(
        title: subject.subjectName,
        onTap: onTap,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: AppSizes.iconSm,
          color: colorScheme.onSurfaceVariant,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.subjectCode,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'View subject analytics',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
