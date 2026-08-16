import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/stat_tile.dart';
import 'package:veriattend_app/features/analytics/department_analytics/domain/model/department_summary_model.dart';

class DepartmentSummaryCard extends StatelessWidget {
  final DepartmentSummaryModel summary;

  const DepartmentSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Department Summary',
      showArrow: false,
      child: Column(
        children: [
          StatTileRow(
            tiles: [
              StatTile(
                label: 'Students',
                value: summary.totalStudents.toString(),
                color: AppColors.primary,
                icon: Icons.groups_rounded,
              ),
              StatTile(
                label: 'Teachers',
                value: summary.totalTeachers.toString(),
                color: AppColors.success,
                icon: Icons.person_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          const Divider(),
          const SizedBox(height: AppSizes.lg),
          StatTileRow(
            tiles: [
              StatTile(
                label: 'Classes',
                value: summary.totalClasses.toString(),
                color: AppColors.info,
                icon: Icons.school_rounded,
              ),
              StatTile(
                label: 'Subjects',
                value: summary.totalSubjects.toString(),
                color: AppColors.warning,
                icon: Icons.menu_book_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
