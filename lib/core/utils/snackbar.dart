import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

void showErrorSnackBar(BuildContext context, String message) {
  _showSnackBar(
    context: context,
    message: message,
    backgroundColor: AppColors.error,
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  _showSnackBar(
    context: context,
    message: message,
    backgroundColor: AppColors.success,
  );
}

void _showSnackBar({
  required BuildContext context,
  required String message,
  required Color backgroundColor,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final snackBarTheme = Theme.of(context).snackBarTheme;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: snackBarTheme.behavior,
        shape: snackBarTheme.shape,
        margin: snackBarTheme.insetPadding,
        duration: const Duration(seconds: 3),
      ),
    );
}
