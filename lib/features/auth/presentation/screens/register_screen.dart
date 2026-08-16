import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/utils/snackbar.dart';
import 'package:veriattend_app/core/validators/app_validators.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/password_field.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _prnController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _prnController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authProvider.notifier)
        .register(
          userName: _userNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          prn: _prnController.text.trim().toUpperCase(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        showSuccessSnackBar(context, 'Registration successful');
      } else if (next is AuthError) {
        showErrorSnackBar(context, next.message);
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPaddingH,
              vertical: AppSizes.screenPaddingV,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.how_to_reg_rounded,
                        size: AppSizes.iconXl,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Register as a student',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xxl),

                  TextFormField(
                    controller: _userNameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(
                        Icons.person_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    validator: AppValidators.userName,
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    validator: AppValidators.email,
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _prnController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: InputDecoration(
                      labelText: 'PRN',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      hintText: 'e.g. RBT23CS130',
                    ),
                    validator: AppValidators.prn,
                  ),
                  const SizedBox(height: AppSizes.md),

                  PasswordField(
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: AppValidators.password,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  AppButton(
                    label: 'Register',
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppSizes.md),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
