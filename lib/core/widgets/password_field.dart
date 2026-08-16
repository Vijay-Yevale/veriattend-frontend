import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      obscureText: !_visible,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
      validator: widget.validator,
    );
  }
}
