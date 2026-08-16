import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_text_field.dart';
import 'package:veriattend_app/features/teacher/domain/model/assessment_type_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/class_roaster_model.dart';

class MarkEntryTile extends StatelessWidget {
  final ClassRosterEntryModel entry;
  final AssessmentType assessmentType;
  final TextEditingController controller;

  const MarkEntryTile({
    super.key,
    required this.entry,
    required this.assessmentType,
    required this.controller,
  });

  String get _contextLabel {
    switch (assessmentType) {
      case AssessmentType.quiz:
        return entry.quizAverage == null
            ? 'No quiz marks yet'
            : '${entry.quizMarks.length} entered · Avg ${entry.quizAverage!.toStringAsFixed(1)}';

      case AssessmentType.assignment:
        return entry.assignmentAverage == null
            ? 'No assignment marks yet'
            : '${entry.assignmentMarks.length} entered · Avg ${entry.assignmentAverage!.toStringAsFixed(1)}';

      case AssessmentType.internal:
        return entry.internalMarks == null
            ? 'Internal marks not set'
            : 'Current internal: ${entry.internalMarks}';
    }
  }

  String get _fieldLabel {
    switch (assessmentType) {
      case AssessmentType.quiz:
        return 'Quiz ${entry.quizMarks.length + 1}';

      case AssessmentType.assignment:
        return 'Assignment ${entry.assignmentMarks.length + 1}';

      case AssessmentType.internal:
        return 'Internal';
    }
  }

  String? _validate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = num.tryParse(value.trim());

    if (parsed == null) return 'Invalid';

    if (parsed < 0 || parsed > assessmentType.maxMarks) {
      return '0-${assessmentType.maxMarks.toStringAsFixed(0)}';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.mm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.userName.isNotEmpty
                    ? entry.userName[0].toUpperCase()
                    : '?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: AppSizes.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: AppSizes.xs),

                  Text(
                    'PRN : ${entry.prn}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    _contextLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSizes.md),

            SizedBox(
              width: 112,
              child: AppTextField(
                controller: controller,
                labelText: _fieldLabel,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textInputAction: TextInputAction.next,
                validator: _validate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
