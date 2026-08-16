sealed class ActionState {
  const ActionState();
}

class ActionInitial extends ActionState {
  const ActionInitial();
}

class ActionLoading extends ActionState {
  const ActionLoading();
}

class ActionSuccess extends ActionState {
  final String message;

  const ActionSuccess(this.message);
}

class ActionError extends ActionState {
  final String message;

  const ActionError(this.message);
}
