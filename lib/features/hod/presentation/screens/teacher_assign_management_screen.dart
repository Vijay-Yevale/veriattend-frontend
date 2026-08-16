import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:veriattend_app/features/hod/presentation/widgets/assign_teacher_from_widget.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/greeting_section.dart';
import '../../../../../core/widgets/section_card.dart';

import '../widgets/teacher_assignment_list_widget.dart';

class TeacherAssignmentScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentScreen({super.key});

  @override
  ConsumerState<TeacherAssignmentScreen> createState() =>
      _TeacherAssignmentScreenState();
}

class _TeacherAssignmentScreenState
    extends ConsumerState<TeacherAssignmentScreen> {
  bool _showAssignForm = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : 'User';

    return AppScaffold(
      title: 'Teacher Assignment',
      navItems: HodNavItems.items,
      currentRoute: AppRoutes.hodmanage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
          vertical: AppSizes.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingSection(
              userName: userName,
              subtitle:
                  'Assign teachers to classes and subjects in your department.',
            ),

            const SizedBox(height: AppSizes.xl),

            SectionCard(
              title: 'Quick Actions',
              child: AppButton(
                label: _showAssignForm ? 'Cancel' : 'Assign Teacher',
                icon: _showAssignForm
                    ? Icons.close
                    : Icons.assignment_ind_outlined,
                onPressed: () {
                  setState(() {
                    _showAssignForm = !_showAssignForm;
                  });
                },
              ),
            ),

            if (_showAssignForm) ...[
              const SizedBox(height: AppSizes.xl),

              AssignTeacherFormWidget(
                onCompleted: () {
                  setState(() {
                    _showAssignForm = false;
                  });
                },
              ),
            ],

            const SizedBox(height: AppSizes.xl),

            const TeacherAssignmentListWidget(),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
