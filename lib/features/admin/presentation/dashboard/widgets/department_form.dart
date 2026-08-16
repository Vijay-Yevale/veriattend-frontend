import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/validators/app_validators.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_text_field.dart';
import 'package:veriattend_app/core/widgets/form_section.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/providers/admin_action_provider.dart';

class DepartmentFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const DepartmentFormWidget({super.key, required this.onCompleted});

  @override
  ConsumerState<DepartmentFormWidget> createState() =>
      _DepartmentFormWidgetState();
}

class _DepartmentFormWidgetState extends ConsumerState<DepartmentFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();

    _nameController.clear();
    _codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(adminActionProvider);

    ref.listen<ActionState>(adminActionProvider, (previous, next) {
      handleActionState(
        context: context,
        state: next,
        onSuccess: () {
          _clearForm();
          widget.onCompleted();
        },
        onReset: () => ref.read(adminActionProvider.notifier).reset(),
      );
    });

    final isLoading = actionState is ActionLoading;

    return FormSection(
      title: 'Create Department',
      subtitle: 'Add a new department to the institution.',
      icon: Icons.apartment_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _nameController,
              labelText: 'Department Name',
              hintText: 'e.g. Computer Engineering',
              prefixIcon: Icons.business_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  AppValidators.required(value, fieldName: 'Department Name'),
            ),

            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _codeController,
              labelText: 'Department Code',
              hintText: 'e.g. COMP',
              prefixIcon: Icons.badge_outlined,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  AppValidators.required(value, fieldName: 'Department Code'),
            ),

            const SizedBox(height: AppSizes.lg),

            AppButton(
              label: 'Create Department',
              icon: Icons.add,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();

                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      ref
                          .read(adminActionProvider.notifier)
                          .createDepartment(
                            name: _nameController.text.trim(),
                            code: _codeController.text.trim(),
                          );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
