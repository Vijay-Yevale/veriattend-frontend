import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/student_tile_widget.dart';

import 'package:veriattend_app/features/hod/presentation/providers/manage_provider.dart';

class AssignedStudentsSection extends ConsumerWidget {
  final String? classId;
  final String? className;

  const AssignedStudentsSection({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (classId == null) {
      return SectionCard(
        title: 'Assigned Students',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          child: EmptyDashboardWidget(
            title: 'No Class Selected',
            message: 'Select a class to view assigned students.',
            icon: Icons.school_outlined,
          ),
        ),
      );
    }

    final studentsAsync = ref.watch(studentsByClassProvider(classId!));

    return SectionCard(
      title: 'Assigned Students',
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          className ?? 'Class',
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: studentsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.xxl),
          child: AppLoader(),
        ),
        error: (error, stackTrace) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
          child: AppErrorWidget(message: error.toString()),
        ),
        data: (students) {
          if (students.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              child: EmptyDashboardWidget(
                title: 'No Students Assigned',
                message: 'Assign students from the Pending Students section.',
                icon: Icons.groups_outlined,
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              return StudentTile(student: students[index]);
            },
          );
        },
      ),
    );
  }
}
