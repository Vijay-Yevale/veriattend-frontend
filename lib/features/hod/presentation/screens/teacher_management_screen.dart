import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/greeting_section.dart';
import '../../../../../core/widgets/section_card.dart';

import '../widgets/teacher_form_widget.dart';
import '../widgets/teacher_list_widget.dart';

class TeacherManagementScreen extends ConsumerStatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  ConsumerState<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState
    extends ConsumerState<TeacherManagementScreen> {
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : 'User';

    return AppScaffold(
      title: 'Teacher Management',
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
                  'Create and manage teacher accounts for your department.',
            ),

            const SizedBox(height: AppSizes.xl),

            SectionCard(
              title: 'Quick Actions',
              child: AppButton(
                label: _showCreateForm ? 'Cancel' : 'Create Teacher Account',
                icon: _showCreateForm ? Icons.close : Icons.person_add_alt_1,
                onPressed: () {
                  setState(() {
                    _showCreateForm = !_showCreateForm;
                  });
                },
              ),
            ),

            if (_showCreateForm) ...[
              const SizedBox(height: AppSizes.xl),

              TeacherFormWidget(
                onCompleted: () {
                  setState(() {
                    _showCreateForm = false;
                  });
                },
              ),
            ],

            const SizedBox(height: AppSizes.xl),

            const TeacherListWidget(),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
