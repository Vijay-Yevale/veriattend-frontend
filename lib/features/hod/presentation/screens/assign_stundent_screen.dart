import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/confirmation_dialog.dart';
import 'package:veriattend_app/core/widgets/greeting_section.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:veriattend_app/features/hod/presentation/widgets/assign_stundet_section.dart';
import 'package:veriattend_app/features/hod/presentation/widgets/pending_stundents_section.dart';

import '../providers/manage_action_provider.dart';
import '../widgets/assignment_header_card.dart';

class AssignStudentsScreen extends ConsumerStatefulWidget {
  const AssignStudentsScreen({super.key});

  @override
  ConsumerState<AssignStudentsScreen> createState() =>
      _AssignStudentsScreenState();
}

class _AssignStudentsScreenState extends ConsumerState<AssignStudentsScreen> {
  String? _selectedClassId;
  String? _selectedClassName;

  final Set<String> _selectedStudentIds = {};

  void _toggleStudent(String studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
      } else {
        _selectedStudentIds.add(studentId);
      }
    });
  }

  void _resetActionState() {
    ref.read(manageActionProvider.notifier).reset();
  }

  Future<void> _assignStudents() async {
    if (_selectedClassId == null || _selectedStudentIds.isEmpty) {
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Assign Students',
      message:
          'Assign ${_selectedStudentIds.length} student(s) '
          'to ${_selectedClassName ?? "selected class"}?',
      confirmText: 'Assign',
    );

    if (!confirmed || !mounted) return;

    ref
        .read(manageActionProvider.notifier)
        .bulkAssignStudents(
          classId: _selectedClassId!,
          studentIds: _selectedStudentIds.toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ActionState>(manageActionProvider, (previous, next) {
      handleActionState(
        context: context,
        state: next,
        onSuccess: () {
          setState(() {
            _selectedStudentIds.clear();
          });
        },
        onReset: _resetActionState,
      );
    });

    final actionState = ref.watch(manageActionProvider);

    final authState = ref.watch(authProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : 'User';

    final hasSelection =
        _selectedStudentIds.isNotEmpty && _selectedClassId != null;

    return AppScaffold(
      title: 'Assign Students',
      navItems: HodNavItems.items,
      currentRoute: AppRoutes.hodmanage,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
            vertical: AppSizes.screenPaddingV,
          ),
          children: [
            GreetingSection(
              userName: userName,
              subtitle:
                  'Assign unallocated students to their respective classes.',
            ),

            const SizedBox(height: AppSizes.xl),

            AssignmentHeaderCard(
              selectedClassId: _selectedClassId,
              onClassChanged: (classId, className) {
                setState(() {
                  _selectedClassId = classId;
                  _selectedClassName = className;
                  _selectedStudentIds.clear();
                });
              },
            ),

            const SizedBox(height: AppSizes.xl),

            PendingStudentsSection(
              selectedStudentIds: _selectedStudentIds,
              onToggleStudent: _toggleStudent,
            ),

            const SizedBox(height: AppSizes.lg),

            AppButton(
              label: _selectedStudentIds.isEmpty
                  ? 'Assign Students'
                  : 'Assign Students (${_selectedStudentIds.length})',
              icon: Icons.assignment_turned_in_outlined,
              isLoading: actionState is ActionLoading,
              onPressed: hasSelection ? _assignStudents : null,
            ),

            const SizedBox(height: AppSizes.xl),

            AssignedStudentsSection(
              classId: _selectedClassId,
              className: _selectedClassName,
            ),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
