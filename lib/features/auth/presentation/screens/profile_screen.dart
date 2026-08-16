import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/confirmation_dialog.dart';
import 'package:veriattend_app/core/widgets/profile_header.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textSecondary = colorScheme.onSurfaceVariant;

    final role = authState is AuthAuthenticated ? authState.user.role : null;

    return AppScaffold(
      title: 'Profile',
      currentRoute: _profileRouteForRole(role),
      navItems: _navItemsForRole(role),
      body: switch (authState) {
        AuthLoading() => const AppLoader(),

        AuthError(:final message) => AppErrorWidget(
          message: message,
          onRetry: () {
            ref.read(authProvider.notifier).checkAuth();
          },
        ),

        AuthAuthenticated(:final user) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(authProvider.notifier).checkAuth();
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              ProfileHeader(user: user),

              const SizedBox(height: AppSizes.xl),

              SectionCard(
                title: 'Account Information',
                showArrow: false,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: textSecondary),
                      title: Text(
                        'Email',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ),

                    const Divider(height: 1),

                    ListTile(
                      leading: Icon(Icons.badge_outlined, color: textSecondary),
                      title: Text(
                        'Role',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        _formatRole(user.role),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ),

                    if (user.department != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.apartment_outlined,
                          color: textSecondary,
                        ),
                        title: Text(
                          'Department',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          user.department!.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              if (user.role.toUpperCase() == 'STUDENT') ...[
                SectionCard(
                  title: 'Face Recognition',
                  showArrow: false,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.face_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      'Register Face',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Register your face for secure attendance',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppSizes.iconSm,
                      color: textSecondary,
                    ),
                    onTap: () => context.push(AppRoutes.studentFaceEnrollRoute),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),
              ],

              SectionCard(
                title: 'Account',
                showArrow: false,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout_rounded, color: colorScheme.error),
                  title: Text(
                    'Logout',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    final confirmed = await ConfirmationDialog.show(
                      context,
                      title: 'Logout',
                      message: 'Are you sure you want to logout?',
                      confirmText: 'Logout',
                      isDestructive: true,
                    );

                    if (!confirmed) return;

                    await ref.read(authProvider.notifier).logout();
                  },
                ),
              ),
            ],
          ),
        ),

        _ => const AppLoader(),
      },
    );
  }

  static String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'STUDENT':
        return 'Student';
      case 'TEACHER':
        return 'Teacher';
      case 'HOD':
        return 'Head of Department';
      case 'SUPER_ADMIN':
        return 'Super Admin';
      default:
        return role;
    }
  }

  static String _profileRouteForRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'TEACHER':
        return AppRoutes.teacherProfile;
      case 'HOD':
        return AppRoutes.hodProfile;
      case 'SUPER_ADMIN':
        return AppRoutes.adminProfile;
      case 'STUDENT':
      default:
        return AppRoutes.studentProfile;
    }
  }

  // TeacherNavItems / HodNavItems / AdminNavItems must each expose a
  // static `items` list, mirroring StudentNavItems.items.
  static _navItemsForRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'TEACHER':
        return TeacherNavItems.items;
      case 'HOD':
        return HodNavItems.items;
      case 'SUPER_ADMIN':
        return AdminNavItems.items;
      case 'STUDENT':
      default:
        return StudentNavItems.items;
    }
  }
}
