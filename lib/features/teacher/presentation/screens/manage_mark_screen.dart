// lib/features/teacher/presentation/screens/manage_mark_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/model/subject_info_model.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_drop_down.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/form_section.dart';
import 'package:veriattend_app/core/widgets/info_row.dart';
import 'package:veriattend_app/features/teacher/domain/model/assessment_type_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/class_roaster_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/mark_entry_model.dart';
import 'package:veriattend_app/features/teacher/domain/model/teacher_class_summary_model.dart';
import 'package:veriattend_app/features/teacher/presentation/providers/academic_record.dart';
import 'package:veriattend_app/features/teacher/presentation/providers/mark_submit_action_provider.dart';
import 'package:veriattend_app/features/teacher/presentation/providers/teacher_provider.dart';
import 'package:veriattend_app/features/teacher/presentation/widgets/mark_entry_tile.dart';

class ManageMarksScreen extends ConsumerStatefulWidget {
  const ManageMarksScreen({super.key});

  @override
  ConsumerState<ManageMarksScreen> createState() => _ManageMarksScreenState();
}

class _ManageMarksScreenState extends ConsumerState<ManageMarksScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _markControllers = {};

  TeacherClassSummaryModel? _selectedClass;
  SubjectInfoModel? _selectedSubject;
  AssessmentType? _selectedAssessment;

  @override
  void dispose() {
    _clearMarkControllers();
    super.dispose();
  }

  void _clearMarkControllers() {
    for (final controller in _markControllers.values) {
      controller.dispose();
    }

    _markControllers.clear();
  }

  TextEditingController _controllerFor(ClassRosterEntryModel entry) {
    return _markControllers.putIfAbsent(entry.studentId, () {
      final initialText = _selectedAssessment == AssessmentType.internal
          ? (entry.internalMarks?.toString() ?? '')
          : '';

      return TextEditingController(text: initialText);
    });
  }

  void _onClassChanged(TeacherClassSummaryModel? value) {
    setState(() {
      _selectedClass = value;
      _selectedSubject = null;
      _selectedAssessment = null;
      _clearMarkControllers();
    });
  }

  void _onSubjectChanged(SubjectInfoModel? value) {
    setState(() {
      _selectedSubject = value;
      _selectedAssessment = null;
      _clearMarkControllers();
    });
  }

  void _onAssessmentChanged(AssessmentType? value) {
    setState(() {
      _selectedAssessment = value;
      _clearMarkControllers();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? AppColors.error
              : colorScheme.brightness == Brightness.dark
              ? AppColors.success
              : AppColors.primaryDark,
        ),
      );
  }

  String _messageFor(Object error) {
    if (error is Failure) return error.message;

    return 'Something went wrong. Please try again.';
  }

  Future<void> _handleRefresh() async {
    if (_selectedClass != null && _selectedSubject != null) {
      ref.invalidate(
        classRosterProvider((
          classId: _selectedClass!.classId,
          subjectId: _selectedSubject!.subjectId,
        )),
      );
    } else {
      ref.invalidate(myClassesProvider);
    }
  }

  Future<void> _handleSave(List<ClassRosterEntryModel> roster) async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      _showSnackBar('Please fix the highlighted marks before saving.');
      return;
    }

    final records = <MarkEntryModel>[];

    for (final entry in roster) {
      final text = _markControllers[entry.studentId]?.text.trim() ?? '';

      if (text.isEmpty) continue;

      final parsed = num.tryParse(text);

      if (parsed == null) continue;

      records.add(MarkEntryModel(studentId: entry.studentId, mark: parsed));
    }

    if (records.isEmpty) {
      _showSnackBar('Enter at least one mark before saving.');
      return;
    }

    await ref
        .read(marksSubmitActionProvider.notifier)
        .submitMarks(
          classId: _selectedClass!.classId,
          subjectId: _selectedSubject!.subjectId,
          type: _selectedAssessment!,
          records: records,
        );
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(myClassesProvider);

    AsyncValue<List<ClassRosterEntryModel>>? rosterAsync;

    if (_selectedClass != null && _selectedSubject != null) {
      rosterAsync = ref.watch(
        classRosterProvider((
          classId: _selectedClass!.classId,
          subjectId: _selectedSubject!.subjectId,
        )),
      );
    }

    ref.listen<ActionState>(marksSubmitActionProvider, (previous, next) {
      if (!mounted) return;

      if (next is ActionSuccess) {
        _showSnackBar(next.message);

        setState(_clearMarkControllers);

        ref.read(marksSubmitActionProvider.notifier).reset();
      } else if (next is ActionError) {
        _showSnackBar(next.message, isError: true);

        ref.read(marksSubmitActionProvider.notifier).reset();
      }
    });

    final isSaving = ref.watch(marksSubmitActionProvider) is ActionLoading;

    return AppScaffold(
      title: 'Manage Marks',
      navItems: TeacherNavItems.items,
      currentRoute: AppRoutes.teacherManage,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
            vertical: AppSizes.screenPaddingV,
          ),
          child: Column(
            children: [
              _buildSelectors(classesAsync),

              const SizedBox(height: AppSizes.lg),

              _buildRosterArea(rosterAsync),

              const SizedBox(height: AppSizes.md),

              _buildSaveButton(rosterAsync, isSaving),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectors(
    AsyncValue<List<TeacherClassSummaryModel>> classesAsync,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return FormSection(
      title: 'Academic Management',
      subtitle: 'Select class, subject and assessment type',
      icon: Icons.edit_note_rounded,
      child: Column(
        children: [
          classesAsync.when(
            loading: () => AppDropdown<TeacherClassSummaryModel>(
              value: null,
              items: const [],
              onChanged: null,
              labelText: 'Class',
              hintText: 'Loading classes...',
              prefixIcon: Icons.class_outlined,
              enabled: false,
            ),
            error: (error, _) => AppDropdown<TeacherClassSummaryModel>(
              value: null,
              items: const [],
              onChanged: null,
              labelText: 'Class',
              hintText: 'Failed to load classes',
              prefixIcon: Icons.class_outlined,
              enabled: false,
            ),
            data: (classes) => AppDropdown<TeacherClassSummaryModel>(
              value: _selectedClass,
              items: classes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.className, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: _onClassChanged,
              labelText: 'Class',
              hintText: 'Select class',
              prefixIcon: Icons.class_outlined,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          AppDropdown<SubjectInfoModel>(
            value: _selectedSubject,
            items: (_selectedClass?.subjects ?? const [])
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      '${s.subjectName} (${s.subjectCode})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: _selectedClass == null ? null : _onSubjectChanged,
            labelText: 'Subject',
            hintText: 'Select subject',
            prefixIcon: Icons.menu_book_outlined,
            enabled: _selectedClass != null,
          ),

          const SizedBox(height: AppSizes.lg),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Assessment Type',
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _selectedSubject == null ? 0.45 : 1,
            child: IgnorePointer(
              ignoring: _selectedSubject == null,
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.xs),
                    child: SegmentedButton<AssessmentType>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: AppSizes.sm,
                          ),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return colorScheme.primary;
                          }

                          return Colors.transparent;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return colorScheme.onPrimary;
                          }

                          return colorScheme.onSurfaceVariant;
                        }),
                        side: WidgetStateProperty.all(BorderSide.none),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      segments: AssessmentType.values
                          .map(
                            (type) => ButtonSegment(
                              value: type,
                              label: Text(
                                type.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      selected: _selectedAssessment == null
                          ? <AssessmentType>{}
                          : {_selectedAssessment!},
                      emptySelectionAllowed: true,
                      onSelectionChanged: (selection) {
                        _onAssessmentChanged(
                          selection.isEmpty ? null : selection.first,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_selectedAssessment != null) ...[
            const SizedBox(height: AppSizes.md),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                ),
              ),
              child: InfoRow(
                icon: Icons.rule_rounded,
                label: 'Maximum Marks',
                value: _selectedAssessment!.maxMarks.toStringAsFixed(0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRosterArea(
    AsyncValue<List<ClassRosterEntryModel>>? rosterAsync,
  ) {
    if (_selectedClass == null) {
      return const EmptyDashboardWidget(
        title: 'Select a class',
        message:
            'Choose a class above to begin entering marks for your students.',
        icon: Icons.class_outlined,
      );
    }

    if (_selectedSubject == null) {
      return const EmptyDashboardWidget(
        title: 'Select a subject',
        message: 'Choose a subject to load the student list.',
        icon: Icons.menu_book_outlined,
      );
    }

    if (_selectedAssessment == null) {
      return const EmptyDashboardWidget(
        title: 'Choose assessment type',
        message: 'Select Quiz, Assignment or Internal to start entering marks.',
        icon: Icons.checklist_rounded,
      );
    }

    return rosterAsync!.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xxl),
        child: AppLoader(),
      ),

      error: (error, _) => AppErrorWidget(
        message: _messageFor(error),
        onRetry: () => ref.invalidate(
          classRosterProvider((
            classId: _selectedClass!.classId,
            subjectId: _selectedSubject!.subjectId,
          )),
        ),
      ),

      data: (roster) {
        if (roster.isEmpty) {
          return const EmptyDashboardWidget(
            title: 'No students found',
            message: 'This class has no students assigned yet.',
            icon: Icons.people_outline_rounded,
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRosterHeader(roster.length),
              const SizedBox(height: AppSizes.md),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: roster.length,
                itemBuilder: (context, index) {
                  final entry = roster[index];

                  return MarkEntryTile(
                    entry: entry,
                    assessmentType: _selectedAssessment!,
                    controller: _controllerFor(entry),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRosterHeader(int studentCount) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(
            Icons.groups_outlined,
            color: colorScheme.primary,
            size: AppSizes.iconMd,
          ),
        ),

        const SizedBox(width: AppSizes.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Marks',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Enter ${_selectedAssessment!.label.toLowerCase()} marks',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Text(
            '$studentCount students',
            style: AppTextStyles.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    AsyncValue<List<ClassRosterEntryModel>>? rosterAsync,
    bool isSaving,
  ) {
    final roster = rosterAsync?.value;

    VoidCallback? onPressed;

    if (_selectedAssessment != null && roster != null && roster.isNotEmpty) {
      onPressed = () => _handleSave(roster);
    }

    return AppButton(
      label: 'Save',
      icon: Icons.save_outlined,
      isLoading: isSaving,
      onPressed: onPressed,
    );
  }
}
