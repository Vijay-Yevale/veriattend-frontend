import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';

import 'package:veriattend_app/features/hod/presentation/providers/manage_provider.dart';

import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/timetable_slot_form_widget.dart';

class TimetableManageArgs {
  final String classId;
  final TimetableSlotModel? slot;

  const TimetableManageArgs({required this.classId, this.slot});
}

class TimetableManagementScreen extends ConsumerWidget {
  final String classId;
  final TimetableSlotModel? slot;

  const TimetableManagementScreen({
    super.key,
    required this.classId,
    this.slot,
  });

  bool get _isEdit => slot != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Timetable Slot' : 'Add Timetable Slot',
          style: AppTextStyles.appBarTitle.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
      ),
      body: SafeArea(
        child: subjectsAsync.when(
          loading: () => const Center(child: AppLoader()),

          error: (error, _) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPaddingH),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: .35),
                  ),
                ),
                child: AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(subjectsProvider),
                ),
              ),
            ),
          ),

          data: (subjects) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPaddingH,
                AppSizes.screenPaddingV,
                AppSizes.screenPaddingH,
                AppSizes.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ManagementHeader(isEdit: _isEdit),

                  const SizedBox(height: AppSizes.lg),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: .35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: .05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TimetableSlotFormWidget(
                      classId: classId,
                      subjects: subjects,
                      slot: slot,
                      onCompleted: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ManagementHeader extends StatelessWidget {
  final bool isEdit;

  const _ManagementHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.primary.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              isEdit
                  ? Icons.edit_calendar_outlined
                  : Icons.calendar_month_outlined,
              color: colorScheme.primary,
              size: AppSizes.iconMd,
            ),
          ),

          const SizedBox(width: AppSizes.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Update timetable slot' : 'Create timetable slot',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: AppSizes.xs),

                Text(
                  isEdit
                      ? 'Modify the schedule details for this class.'
                      : 'Add a subject, time and room to the class timetable.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
