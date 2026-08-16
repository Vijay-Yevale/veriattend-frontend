import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/features/hod/domain/model/subject_model.dart';

import '../providers/manage_provider.dart';

class SubjectListWidget extends ConsumerWidget {
  const SubjectListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return SectionCard(
      title: 'Subjects',
      child: subjectsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: AppLoader(),
        ),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(subjectsProvider),
        ),
        data: (subjects) {
          if (subjects.isEmpty) {
            return const EmptyDashboardWidget(
              title: 'No Subjects',
              message: 'No subjects have been created for your department yet.',
              icon: Icons.menu_book_outlined,
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              return _SubjectTile(subject: subjects[index]);
            },
          );
        },
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(Icons.menu_book_outlined, color: colorScheme.primary),
          ),

          const SizedBox(width: AppSizes.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subjectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppSizes.xs),

                Row(
                  children: [
                    Icon(
                      Icons.qr_code_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      subject.subjectCode,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Icon(
                      Icons.layers_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'Semester ${subject.semester}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
