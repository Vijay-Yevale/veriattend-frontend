import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/student_tile_widget.dart';

import 'package:veriattend_app/features/hod/presentation/providers/manage_provider.dart';

class PendingStudentsSection extends ConsumerWidget {
  final Set<String> selectedStudentIds;

  final ValueChanged<String> onToggleStudent;

  const PendingStudentsSection({
    super.key,
    required this.selectedStudentIds,
    required this.onToggleStudent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(pendingStudentsProvider);

    return SectionCard(
      title: 'Pending Students',
      child: students.when(
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
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: EmptyDashboardWidget(
                title: 'No Pending Students',
                message: 'All students have already been assigned to classes.',
                icon: Icons.check_circle_outline,
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              final student = students[index];

              return StudentTile(
                student: student,
                showCheckbox: true,
                isSelected: selectedStudentIds.contains(student.id),
                onChanged: (_) => onToggleStudent(student.id),
                onTap: () => onToggleStudent(student.id),
              );
            },
          );
        },
      ),
    );
  }
}
