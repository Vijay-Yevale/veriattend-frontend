import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;

  final String labelText;
  final String? hintText;

  final IconData? prefixIcon;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;

  /// Optional input formatters.
  final List<TextInputFormatter>? inputFormatters;

  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,

      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,

      validator: validator,

      style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
