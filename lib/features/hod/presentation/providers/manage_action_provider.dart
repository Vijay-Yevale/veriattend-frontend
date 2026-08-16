import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/features/hod/presentation/providers/manage_provider.dart';

class ManageActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() {
    return const ActionInitial();
  }

  Future<void> createTeacher({
    required String userName,
    required String email,
    required String password,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(manageRepositoryProvider);

      await repository.createTeacher(
        userName: userName,
        email: email,
        password: password,
      );

      // Refresh teacher list
      ref.invalidate(teachersProvider);

      state = const ActionSuccess('Teacher account created successfully.');
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

  Future<void> createClass({
    required String className,
    required String academicYear,
    required int semester,
    String? classTeacherId,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(manageRepositoryProvider);

      await repository.createClass(
        className: className,
        academicYear: academicYear,
        semester: semester,
        classTeacherId: classTeacherId,
      );

      ref.invalidate(classesProvider);

      state = const ActionSuccess('Class created successfully.');
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

  Future<void> createSubject({
    required String subjectName,
    required String subjectCode,
    required int semester,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(manageRepositoryProvider);

      await repository.createSubject(
        subjectName: subjectName,
        subjectCode: subjectCode,
        semester: semester,
      );

      // Refresh subject list
      ref.invalidate(subjectsProvider);

      state = const ActionSuccess('Subject created successfully.');
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

  Future<void> assignTeacher({
    required String teacherId,
    required String subjectId,
    required String classId,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(manageRepositoryProvider);

      await repository.assignTeacher(
        teacherId: teacherId,
        subjectId: subjectId,
        classId: classId,
      );

      // Refresh assignment list
      ref.invalidate(teacherAssignmentsProvider);

      state = const ActionSuccess('Teacher assigned successfully.');
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

  Future<void> bulkAssignStudents({
    required String classId,
    required List<String> studentIds,
  }) async {
    state = const ActionLoading();

    try {
      final repository = ref.read(manageRepositoryProvider);

      await repository.bulkAssignStudents(
        classId: classId,
        studentIds: studentIds,
      );

      // Refresh pending students
      ref.invalidate(pendingStudentsProvider);

      // Refresh selected class students
      ref.invalidate(studentsByClassProvider(classId));

      state = const ActionSuccess('Students assigned successfully.');
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

final manageActionProvider =
    NotifierProvider<ManageActionNotifier, ActionState>(
      ManageActionNotifier.new,
    );
