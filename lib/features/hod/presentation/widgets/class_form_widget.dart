import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/validators/app_validators.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_drop_down.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_text_field.dart';
import 'package:veriattend_app/core/widgets/form_section.dart';

import '../providers/manage_action_provider.dart';
import '../providers/manage_provider.dart';

class ClassFormWidget extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;

  const ClassFormWidget({super.key, this.onCompleted});

  @override
  ConsumerState<ClassFormWidget> createState() => _ClassFormWidgetState();
}

class _ClassFormWidgetState extends ConsumerState<ClassFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final _classNameController = TextEditingController();
  final _academicYearController = TextEditingController();

  int? _selectedSemester;
  String? _selectedTeacherId;

  @override
  void dispose() {
    _classNameController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _classNameController.clear();
    _academicYearController.clear();

    setState(() {
      _selectedSemester = null;
      _selectedTeacherId = null;
    });
  }

  void _resetActionState() {
    ref.read(manageActionProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
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

    final actionState = ref.watch(manageActionProvider);
    final teachersAsync = ref.watch(teachersProvider);

    return FormSection(
      title: 'Create Class',
      subtitle: 'Add a new class to your department.',
      icon: Icons.school_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _classNameController,
              labelText: 'Class Name',
              hintText: 'e.g. SE Computer A',
              prefixIcon: Icons.class_outlined,
              validator: (value) =>
                  AppValidators.required(value, fieldName: 'Class Name'),
            ),

            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _academicYearController,
              labelText: 'Academic Year',
              hintText: 'e.g. 2026-27',
              prefixIcon: Icons.calendar_month_outlined,
              maxLength: 7,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              ],
              validator: AppValidators.academicYear,
            ),

            const SizedBox(height: AppSizes.md),

            AppDropdown<int>(
              value: _selectedSemester,
              labelText: 'Semester',
              prefixIcon: Icons.layers_outlined,
              items: List.generate(
                8,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('Semester ${index + 1}'),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedSemester = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Semester is required' : null,
            ),

            const SizedBox(height: AppSizes.md),

            teachersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                child: AppLoader(),
              ),
              error: (error, stackTrace) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(teachersProvider),
              ),
              data: (teachers) {
                return AppDropdown<String>(
                  value: _selectedTeacherId,
                  labelText: 'Class Teacher',
                  prefixIcon: Icons.person_outline,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Not Assigned'),
                    ),
                    ...teachers.map(
                      (teacher) => DropdownMenuItem<String>(
                        value: teacher.id,
                        child: Text(teacher.userName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTeacherId = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: AppSizes.lg),

            AppButton(
              label: 'Create Class',
              icon: Icons.add,
              isLoading: actionState is ActionLoading,
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                ref
                    .read(manageActionProvider.notifier)
                    .createClass(
                      className: _classNameController.text.trim(),
                      academicYear: _academicYearController.text.trim(),
                      semester: _selectedSemester!,
                      classTeacherId: _selectedTeacherId,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
