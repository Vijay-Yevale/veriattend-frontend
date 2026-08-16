import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';

import 'face_providers.dart';

class FaceActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() {
    return const ActionInitial();
  }

  Future<void> enrollFace({required List<double> embedding}) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(faceRepositoryProvider);

      await repository.enrollFace(embedding: embedding);

      ref.invalidate(faceProfileProvider);
      ref.invalidate(faceRegisteredProvider);

      state = const ActionSuccess('Face registered successfully.');
    } on ValidationFailure catch (e) {
      state = ActionError(e.message);
    } on UnauthorizedFailure catch (e) {
      state = ActionError(e.message);
    } on NetworkFailure catch (e) {
      state = ActionError(e.message);
    } on ServerFailure catch (e) {
      state = ActionError(e.message);
    } catch (_) {
      state = const ActionError('Something went wrong.');
    }
  }

  void reset() {
    state = const ActionInitial();
  }
}

final faceActionProvider = NotifierProvider<FaceActionNotifier, ActionState>(
  FaceActionNotifier.new,
);
