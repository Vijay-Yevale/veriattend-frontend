import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';

class ReasonDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String confirmText;

  const ReasonDialog({
    super.key,
    this.title = "Manual Attendance",
    this.hintText = "Enter reason",
    this.confirmText = "Submit",
  });

  static Future<String?> show(
    BuildContext context, {
    String title = "Manual Attendance",
    String hintText = "Enter reason",
    String confirmText = "Submit",
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReasonDialog(
        title: title,
        hintText: hintText,
        confirmText: confirmText,
      ),
    );
  }

  @override
  State<ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<ReasonDialog> {
  final _controller = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim();

    if (reason.isEmpty) {
      setState(() {
        _error = "Reason is required";
      });
      return;
    }

    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      title: Text(widget.title, style: AppTextStyles.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 150,
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.hintText,
              errorText: _error,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: AppTextStyles.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmText)),
      ],
    );
  }
}
