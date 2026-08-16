import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/validators/app_validators.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_text_field.dart';
import 'package:veriattend_app/core/widgets/form_section.dart';
import 'package:veriattend_app/core/widgets/password_field.dart';

import '../providers/manage_action_provider.dart';

class TeacherFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const TeacherFormWidget({super.key, required this.onCompleted});

  @override
  ConsumerState<TeacherFormWidget> createState() => _TeacherFormWidgetState();
}

class _TeacherFormWidgetState extends ConsumerState<TeacherFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    _userNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();

    _userNameController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(manageActionProvider);

    ref.listen<ActionState>(manageActionProvider, (previous, next) {
      handleActionState(
        context: context,
        state: next,
        onSuccess: () {
          _clearForm();
          widget.onCompleted();
        },
        onReset: () => ref.read(manageActionProvider.notifier).reset(),
      );
    });

    final isLoading = actionState is ActionLoading;

    return FormSection(
      title: 'Create Teacher Account',
      subtitle: 'Create a teacher account for your department.',
      icon: Icons.person_add_alt_1_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _userNameController,
              labelText: 'Full Name',
              hintText: 'e.g. John Doe',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: AppValidators.userName,
            ),

            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'e.g. teacher@college.edu',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.email_outlined,
              validator: AppValidators.email,
            ),

            const SizedBox(height: AppSizes.md),

            PasswordField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              validator: AppValidators.password,
            ),

            const SizedBox(height: AppSizes.lg),

            AppButton(
              label: 'Create Teacher Account',
              icon: Icons.person_add_alt_1,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();

                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      ref
                          .read(manageActionProvider.notifier)
                          .createTeacher(
                            userName: _userNameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
