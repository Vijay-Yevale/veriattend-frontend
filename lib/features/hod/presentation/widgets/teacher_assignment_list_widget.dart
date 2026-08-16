import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

import '../../domain/model/teacher_assignment_model.dart';
import '../providers/manage_provider.dart';

class TeacherAssignmentListWidget extends ConsumerWidget {
  const TeacherAssignmentListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(teacherAssignmentsProvider);

    return SectionCard(
      title: 'Teacher Assignments',
      child: assignmentsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: AppLoader(),
        ),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(teacherAssignmentsProvider),
        ),
        data: (assignments) {
          if (assignments.isEmpty) {
            return const EmptyDashboardWidget(
              title: 'No Assignments',
              message: 'No teachers have been assigned yet.',
              icon: Icons.assignment_ind_outlined,
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignments.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              return _TeacherAssignmentTile(assignment: assignments[index]);
            },
          );
        },
      ),
    );
  }
}

class _TeacherAssignmentTile extends StatelessWidget {
  final TeacherAssignmentModel assignment;

  const _TeacherAssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final statusColor = assignment.isActive
        ? AppColors.success
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              assignment.isActive
                  ? Icons.assignment_ind_outlined
                  : Icons.person_off_outlined,
              color: statusColor,
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
                        assignment.teacher.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSizes.sm),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            assignment.isActive
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            assignment.isActive ? 'Active' : 'Inactive',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.sm),

                _AssignmentDetailRow(
                  icon: Icons.menu_book_outlined,
                  text:
                      '${assignment.subject.subjectName} (${assignment.subject.subjectCode})',
                ),

                const SizedBox(height: AppSizes.xs),

                _AssignmentDetailRow(
                  icon: Icons.groups_outlined,
                  text: assignment.classInfo.className,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AssignmentDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 17, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSizes.xs),
        Expanded(
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
