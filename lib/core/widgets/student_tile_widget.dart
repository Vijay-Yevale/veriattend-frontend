// lib/features/hod/presentation/widgets/student_tile.dart

import 'package:flutter/material.dart';
import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/user_model.dart';

class StudentTile extends StatelessWidget {
  final UserModel student;

  final bool showCheckbox;

  final bool isSelected;

  final bool showEmail;

  final ValueChanged<bool?>? onChanged;

  final VoidCallback? onTap;

  final Widget? trailing;

  const StudentTile({
    super.key,
    required this.student,
    this.showCheckbox = false,
    this.isSelected = false,
    this.showEmail = false,
    this.onChanged,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),

        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: .12),
          child: Text(
            student.userName.isNotEmpty
                ? student.userName[0].toUpperCase()
                : "?",
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        title: Text(
          student.userName,
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (student.prn != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                "PRN : ${student.prn}",
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            if (showEmail && student.email.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                student.email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),

        trailing:
            trailing ??
            (showCheckbox
                ? Checkbox(value: isSelected, onChanged: onChanged)
                : (onTap != null
                      ? Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null)),
      ),
    );
  }
}
