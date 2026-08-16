import 'package:flutter/material.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';

import 'snackbar.dart';

void handleActionState({
  required BuildContext context,
  required ActionState state,
  required VoidCallback onReset,
  required VoidCallback onSuccess,
}) {
  if (state is ActionSuccess) {
    onSuccess();

    showSuccessSnackBar(context, state.message);

    onReset();
  }

  if (state is ActionError) {
    showErrorSnackBar(context, state.message);

    onReset();
  }
}
