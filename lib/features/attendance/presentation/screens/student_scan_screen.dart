import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';

import 'package:veriattend_app/features/attendance/presentation/providers/attendance_active_session_provider.dart';
import 'package:veriattend_app/features/attendance/presentation/widgets/student_active_session_view.dart';
import 'package:veriattend_app/features/attendance/presentation/widgets/student_no_active_session_view.dart';

class StudentScanScreen extends ConsumerWidget {
  const StudentScanScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(studentActiveSessionProvider);

    try {
      await ref.read(studentActiveSessionProvider.future);
    } catch (_) {
      // AsyncValue handles the error state.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(studentActiveSessionProvider);

    return AppScaffold(
      title: 'Scan Attendance',
      currentRoute: AppRoutes.studentScanQrRoute,
      navItems: StudentNavItems.items,
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenPaddingH,
                    vertical: AppSizes.screenPaddingV,
                  ),
                  child: sessionAsync.when(
                    loading: () => const SizedBox(
                      height: 300,
                      child: Center(child: AppLoader()),
                    ),

                    error: (error, stack) {
                      final message = error.toString();

                      // Student has not been assigned to a class.
                      if (message.contains(
                        'Student is not assigned to any class',
                      )) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          child: const Align(
                            alignment: Alignment(0, -0.25),
                            child: EmptyDashboardWidget(
                              icon: Icons.school_outlined,
                              title: 'No Class Assigned',
                              message:
                                  'You have not been assigned to a class yet. '
                                  'Please contact your HOD or administrator.',
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: constraints.maxHeight,
                        child: Center(
                          child: AppErrorWidget(
                            message: 'Something went wrong. Please try again.',
                            onRetry: () => _refresh(ref),
                          ),
                        ),
                      );
                    },

                    data: (session) {
                      if (session == null) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          child: const Align(
                            alignment: Alignment(0, -0.25),
                            child: StudentNoActiveSessionView(),
                          ),
                        );
                      }

                      return StudentActiveSessionView(
                        session: session,
                        onScan: () {
                          context.push(AppRoutes.studentQrScannerRoute);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
