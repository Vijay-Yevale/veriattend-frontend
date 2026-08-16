import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_drop_down.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/form_section.dart';

import '../providers/manage_action_provider.dart';
import '../providers/manage_provider.dart';

class AssignTeacherFormWidget extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;

  const AssignTeacherFormWidget({super.key, this.onCompleted});

  @override
  ConsumerState<AssignTeacherFormWidget> createState() =>
      _AssignTeacherFormWidgetState();
}

class _AssignTeacherFormWidgetState
    extends ConsumerState<AssignTeacherFormWidget> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedTeacherId;
  String? _selectedSubjectId;
  String? _selectedClassId;

  void _clearForm() {
    setState(() {
      _selectedTeacherId = null;
      _selectedSubjectId = null;
      _selectedClassId = null;
    });
  }

  void _resetActionState() {
    ref.read(manageActionProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<ActionState>(manageActionProvider, (previous, next) {
      handleActionState(
        context: context,
        state: next,
        onSuccess: () {
          _clearForm();
          widget.onCompleted?.call();
        },
        onReset: _resetActionState,
      );
    });

    final teachersAsync = ref.watch(teachersProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final classesAsync = ref.watch(classesProvider);

    final actionState = ref.watch(manageActionProvider);

    return FormSection(
      title: 'Assign Teacher',
      subtitle: 'Assign a teacher to a class and subject.',
      icon: Icons.assignment_ind_outlined,
      child: teachersAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.md),
          child: AppLoader(),
        ),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(teachersProvider),
        ),
        data: (teachers) {
          return subjectsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: AppLoader(),
            ),
            error: (error, _) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(subjectsProvider),
            ),
            data: (subjects) {
              return classesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: AppLoader(),
                ),
                error: (error, _) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(classesProvider),
                ),
                data: (classes) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppDropdown<String>(
                          value: _selectedTeacherId,
                          labelText: 'Teacher',
                          prefixIcon: Icons.person_outline,
                          items: teachers
                              .map(
                                (teacher) => DropdownMenuItem(
                                  value: teacher.id,
                                  child: Text(
                                    teacher.userName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTeacherId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Teacher is required' : null,
                        ),

                        const SizedBox(height: AppSizes.md),

                        AppDropdown<String>(
                          value: _selectedSubjectId,
                          labelText: 'Subject',
                          prefixIcon: Icons.menu_book_outlined,
                          items: subjects
                              .map(
                                (subject) => DropdownMenuItem(
                                  value: subject.subjectId,
                                  child: Text(
                                    '${subject.subjectName} (${subject.subjectCode})',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubjectId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Subject is required' : null,
                        ),

                        const SizedBox(height: AppSizes.md),

                        AppDropdown<String>(
                          value: _selectedClassId,
                          labelText: 'Class',
                          prefixIcon: Icons.groups_outlined,
                          items: classes
                              .map(
                                (classItem) => DropdownMenuItem(
                                  value: classItem.id,
                                  child: Text(
                                    classItem.className,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClassId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Class is required' : null,
                        ),

                        const SizedBox(height: AppSizes.lg),

                        AppButton(
                          label: 'Assign Teacher',
                          icon: Icons.assignment_turned_in_outlined,
                          isLoading: actionState is ActionLoading,
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            ref
                                .read(manageActionProvider.notifier)
                                .assignTeacher(
                                  teacherId: _selectedTeacherId!,
                                  subjectId: _selectedSubjectId!,
                                  classId: _selectedClassId!,
                                );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
