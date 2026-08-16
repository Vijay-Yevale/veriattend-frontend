import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/greeting_section.dart';
import '../../../../../core/widgets/section_card.dart';

import '../widgets/class_form_widget.dart';
import '../widgets/class_list_widget.dart';

class ClassManagementScreen extends ConsumerStatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ConsumerState<ClassManagementScreen> createState() =>
      _ClassManagementScreenState();
}

class _ClassManagementScreenState extends ConsumerState<ClassManagementScreen> {
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : 'User';

    return AppScaffold(
      title: 'Class Management',
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
              subtitle: 'Create and manage classes for your department.',
            ),

            const SizedBox(height: AppSizes.xl),

            SectionCard(
              title: 'Quick Actions',
              child: AppButton(
                label: _showCreateForm ? 'Cancel' : 'Create New Class',
                icon: _showCreateForm
                    ? Icons.close
                    : Icons.add_business_outlined,
                onPressed: () {
                  setState(() {
                    _showCreateForm = !_showCreateForm;
                  });
                },
              ),
            ),

            if (_showCreateForm) ...[
              const SizedBox(height: AppSizes.xl),

              ClassFormWidget(
                onCompleted: () {
                  setState(() {
                    _showCreateForm = false;
                  });
                },
              ),
            ],

            const SizedBox(height: AppSizes.xl),

            const ClassListWidget(),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
