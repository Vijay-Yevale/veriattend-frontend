import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';

import '../../../../../core/errors/failures.dart';

import '../../../presentation/dashboard/providers/department_provider.dart';

class AdminActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() {
    return const ActionInitial();
  }

  Future<void> createDepartment({
    required String name,
    required String code,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(adminRepositoryProvider);

      await repository.createDepartment(name: name, code: code);

      ref.invalidate(departmentsProvider);

      state = const ActionSuccess('Department created successfully.');
    } on ValidationFailure catch (e) {
      state = ActionError(e.message);
    } on ConflictFailure catch (e) {
      state = ActionError(e.message);
    } on NetworkFailure catch (e) {
      state = ActionError(e.message);
    } on ServerFailure catch (e) {
      state = ActionError(e.message);
    } catch (_) {
      state = const ActionError('Something went wrong.');
    }
  }

  Future<void> createHod({
    required String userName,
    required String email,
    required String password,
    required String departmentId,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(adminRepositoryProvider);

      await repository.createHod(
        userName: userName,
        email: email,
        password: password,
        departmentId: departmentId,
      );

      state = const ActionSuccess('HOD account created successfully.');
    } on ValidationFailure catch (e) {
      state = ActionError(e.message);
    } on ConflictFailure catch (e) {
      state = ActionError(e.message);
    } on NotFoundFailure catch (e) {
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

final adminActionProvider = NotifierProvider<AdminActionNotifier, ActionState>(
  AdminActionNotifier.new,
);
