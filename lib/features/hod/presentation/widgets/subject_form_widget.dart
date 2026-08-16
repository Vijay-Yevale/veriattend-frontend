import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/validators/app_validators.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_drop_down.dart';
import 'package:veriattend_app/core/widgets/app_text_field.dart';
import 'package:veriattend_app/core/widgets/form_section.dart';

import '../providers/manage_action_provider.dart';

class SubjectFormWidget extends ConsumerStatefulWidget {
  final VoidCallback? onCompleted;

  const SubjectFormWidget({super.key, this.onCompleted});

  @override
  ConsumerState<SubjectFormWidget> createState() => _SubjectFormWidgetState();
}

class _SubjectFormWidgetState extends ConsumerState<SubjectFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();

  int? _selectedSemester;

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _subjectNameController.clear();
    _subjectCodeController.clear();

    setState(() {
      _selectedSemester = null;
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

    return FormSection(
      title: 'Create Subject',
      subtitle: 'Add a new subject to your department.',
      icon: Icons.menu_book_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _subjectNameController,
              labelText: 'Subject Name',
              hintText: 'e.g. Data Structures',
              prefixIcon: Icons.book_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  AppValidators.required(value, fieldName: 'Subject Name'),
            ),

            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _subjectCodeController,
              labelText: 'Subject Code',
              hintText: 'e.g. CS301',
              prefixIcon: Icons.qr_code_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  AppValidators.required(value, fieldName: 'Subject Code'),
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

            const SizedBox(height: AppSizes.lg),

            AppButton(
              label: 'Create Subject',
              icon: Icons.add,
              isLoading: actionState is ActionLoading,
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                FocusScope.of(context).unfocus();

                ref
                    .read(manageActionProvider.notifier)
                    .createSubject(
                      subjectName: _subjectNameController.text.trim(),
                      subjectCode: _subjectCodeController.text.trim(),
                      semester: _selectedSemester!,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
