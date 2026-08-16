import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/core/widgets/app_drop_down.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/stat_tile.dart';

import '../providers/manage_provider.dart';

class AssignmentHeaderCard extends ConsumerWidget {
  final String? selectedClassId;

  final void Function(String? classId, String? className) onClassChanged;

  const AssignmentHeaderCard({
    super.key,
    required this.selectedClassId,
    required this.onClassChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final classesAsync = ref.watch(classesProvider);
    final pendingAsync = ref.watch(pendingStudentsProvider);

    return SectionCard(
      title: 'Assignment Details',
      child: classesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.md),
          child: AppLoader(),
        ),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(classesProvider),
        ),
        data: (classes) {
          ClassModel? selectedClass;

          if (selectedClassId != null) {
            try {
              selectedClass = classes.firstWhere(
                (element) => element.id == selectedClassId,
              );
            } catch (_) {
              selectedClass = null;
            }
          }

          final assignedAsync = selectedClassId == null
              ? null
              : ref.watch(studentsByClassProvider(selectedClassId!));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDropdown<String>(
                value: selectedClassId,
                labelText: 'Class',
                prefixIcon: Icons.groups_outlined,
                items: classes
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(
                          c.className,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    onClassChanged(null, null);
                    return;
                  }

                  final selected = classes.firstWhere((c) => c.id == value);

                  onClassChanged(selected.id, selected.className);
                },
              ),

              if (selectedClass != null) ...[
                const SizedBox(height: AppSizes.md),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      _AssignmentInfoRow(
                        icon: Icons.layers_outlined,
                        label: 'Semester',
                        value: '${selectedClass.semester}',
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _AssignmentInfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Academic Year',
                        value: selectedClass.academicYear,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.lg),

              pendingAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                  child: AppLoader(),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (pendingStudents) {
                  final assignedCount =
                      assignedAsync?.maybeWhen(
                        data: (students) => students.length.toString(),
                        orElse: () => '--',
                      ) ??
                      '--';

                  return StatTileRow(
                    tiles: [
                      StatTile(
                        label: 'Pending',
                        value: pendingStudents.length.toString(),
                        color: AppColors.warning,
                        icon: Icons.pending_actions_outlined,
                      ),
                      StatTile(
                        label: 'Assigned',
                        value: assignedCount,
                        color: AppColors.primary,
                        icon: Icons.groups_outlined,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssignmentInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AssignmentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: AppSizes.iconLg,
          height: AppSizes.iconLg,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            icon,
            size: AppSizes.iconSm + 2,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
