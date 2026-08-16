import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/utils/time_format.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/info_row.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

import 'package:veriattend_app/features/attendance/domain/model/attendance_active_session_model.dart';

class StudentActiveSessionView extends StatelessWidget {
  final AttendanceActiveSessionModel session;
  final VoidCallback onScan;

  const StudentActiveSessionView({
    super.key,
    required this.session,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            title: "Current Lecture",
            showArrow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.subject.subjectName,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true,
                ),

                const SizedBox(height: AppSizes.md),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm + 2,
                    vertical: AppSizes.xs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Attendance Active",
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: "Teacher",
                  value: session.teacher.userName,
                ),

                const SizedBox(height: AppSizes.md),

                InfoRow(
                  icon: Icons.access_time_rounded,
                  label: "Lecture Time",
                  value:
                      "${formatTime12Hr(session.startTime)} - ${formatTime12Hr(session.endTime)}",
                ),

                const SizedBox(height: AppSizes.md),

                const InfoRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: "Status",
                  value: "Attendance Active",
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          SectionCard(
            title: "Attendance",
            showArrow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Your teacher has started attendance for this lecture.",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                AppButton(
                  label: "Scan Attendance QR",
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: onScan,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          SectionCard(
            title: "Instructions",
            showArrow: false,
            child: const Column(
              children: [
                _InstructionItem(
                  "Scan only the QR code displayed by your teacher.",
                ),
                SizedBox(height: AppSizes.md),
                _InstructionItem("The QR code refreshes every few seconds."),
                SizedBox(height: AppSizes.md),
                _InstructionItem(
                  "Remain inside the classroom while submitting attendance.",
                ),
                SizedBox(height: AppSizes.md),
                _InstructionItem(
                  "Attendance will be verified before it is accepted.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String text;

  const _InstructionItem(this.text);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 15,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: AppSizes.sm),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              softWrap: true,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
