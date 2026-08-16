import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/greeting_section.dart';
import '../../../../../core/widgets/section_card.dart';

import '../widgets/subject_form_widget.dart';
import '../widgets/subject_list_widget.dart';

class SubjectManagementScreen extends ConsumerStatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  ConsumerState<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState
    extends ConsumerState<SubjectManagementScreen> {
  bool _showCreateForm = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : 'User';

    return AppScaffold(
      title: 'Subject Management',
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
              subtitle: 'Create and manage subjects for your department.',
            ),

            const SizedBox(height: AppSizes.xl),

            SectionCard(
              title: 'Quick Actions',
              child: AppButton(
                label: _showCreateForm ? 'Cancel' : 'Create New Subject',
                icon: _showCreateForm ? Icons.close : Icons.menu_book_outlined,
                onPressed: () {
                  setState(() {
                    _showCreateForm = !_showCreateForm;
                  });
                },
              ),
            ),

            if (_showCreateForm) ...[
              const SizedBox(height: AppSizes.xl),

              SubjectFormWidget(
                onCompleted: () {
                  setState(() {
                    _showCreateForm = false;
                  });
                },
              ),
            ],

            const SizedBox(height: AppSizes.xl),

            const SubjectListWidget(),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}
