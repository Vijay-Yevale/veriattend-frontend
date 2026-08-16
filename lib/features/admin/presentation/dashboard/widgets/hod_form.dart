import 'package:flutter/material.dart';
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
import 'package:veriattend_app/core/widgets/password_field.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/providers/admin_action_provider.dart';
import 'package:veriattend_app/features/admin/presentation/dashboard/providers/department_provider.dart';

class HodFormWidget extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const HodFormWidget({super.key, required this.onCompleted});

  @override
  ConsumerState<HodFormWidget> createState() => _HodFormWidgetState();
}

class _HodFormWidgetState extends ConsumerState<HodFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  String? _departmentId;

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

    setState(() {
      _departmentId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final departmentsAsync = ref.watch(departmentsProvider);

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

    return departmentsAsync.when(
      loading: () => const AppLoader(),
      error: (error, stackTrace) => AppErrorWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(departmentsProvider),
      ),
      data: (departments) {
        return FormSection(
          title: 'Create HOD Account',
          subtitle: 'Assign a Head of Department.',
          icon: Icons.person_add_alt_1_outlined,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _userNameController,
                  labelText: 'Full Name',
                  hintText: 'e.g. Dr. John Doe',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.userName,
                ),

                const SizedBox(height: AppSizes.md),

                AppTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'e.g. hod@college.edu',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  validator: AppValidators.email,
                ),

                const SizedBox(height: AppSizes.md),

                PasswordField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.password,
                ),

                const SizedBox(height: AppSizes.md),

                AppDropdown<String>(
                  value: _departmentId,
                  labelText: 'Department',
                  prefixIcon: Icons.apartment_outlined,
                  validator: (value) {
                    if (value == null) {
                      return 'Department is required';
                    }
                    return null;
                  },
                  items: departments
                      .map(
                        (department) => DropdownMenuItem<String>(
                          value: department.id,
                          child: Text(department.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _departmentId = value;
                    });
                  },
                ),

                const SizedBox(height: AppSizes.lg),

                AppButton(
                  label: 'Create HOD Account',
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
                              .read(adminActionProvider.notifier)
                              .createHod(
                                userName: _userNameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                departmentId: _departmentId!,
                              );
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
