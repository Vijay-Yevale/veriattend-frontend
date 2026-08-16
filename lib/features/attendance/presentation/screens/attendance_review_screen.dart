import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/utils/snackbar.dart';

import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/app_search_bar.dart';
import 'package:veriattend_app/core/widgets/confirmation_dialog.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/reason_dialog.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/stat_tile.dart';

import 'package:veriattend_app/features/attendance/domain/model/attendance_session_roster_model.dart';
import 'package:veriattend_app/features/attendance/presentation/providers/attendance_session_review_provider.dart';
import 'package:veriattend_app/features/attendance/presentation/widgets/attendance_student_tile.dart';

class AttendanceReviewScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AttendanceReviewScreen({super.key, required this.sessionId});

  @override
  ConsumerState<AttendanceReviewScreen> createState() =>
      _AttendanceReviewScreenState();
}

class _AttendanceReviewScreenState
    extends ConsumerState<AttendanceReviewScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  final Set<String> _selectedStudents = <String>{};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showReasonDialog() async {
    if (_isSubmitting) return;

    final selectedStudents = _selectedStudents.toList();

    if (selectedStudents.isEmpty) return;

    final reason = await ReasonDialog.show(
      context,
      title: 'Manual Attendance',
      hintText: 'Enter reason for manual attendance',
      confirmText: 'Mark Present',
    );

    if (!mounted || reason == null) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Confirm Attendance',
      message:
          'Mark ${selectedStudents.length} selected student(s) '
          'as Present?\n\n'
          'Reason:\n$reason',
      confirmText: 'Confirm',
    );

    if (!mounted || !confirmed) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(sessionReviewProvider(widget.sessionId).notifier)
          .markManualAttendance(studentIds: selectedStudents, reason: reason);

      if (!mounted) return;

      setState(() {
        _selectedStudents.clear();
      });

      showSuccessSnackBar(context, 'Attendance updated successfully.');
    } on Failure catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.message);
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(sessionReviewProvider(widget.sessionId));

    return AppScaffold(
      title: 'Session Review',
      currentRoute: AppRoutes.teacherSessionHistoryRoute,
      navItems: TeacherNavItems.items,
      body: _buildBody(reviewState),
    );
  }

  Widget _buildBody(SessionReviewState state) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(sessionReviewProvider(widget.sessionId).notifier).refresh(),
      child: switch (state) {
        SessionReviewLoading() => _scrollableCenter(const AppLoader()),
        SessionReviewError(:final isNotFound) when isNotFound =>
          _scrollableCenter(_buildNotFoundState()),
        SessionReviewError(:final message) => _scrollableCenter(
          AppErrorWidget(
            message: message,
            onRetry: () => ref
                .read(sessionReviewProvider(widget.sessionId).notifier)
                .refresh(),
          ),
        ),
        SessionReviewLoaded(:final roster, :final isMarking) => _buildContent(
          roster,
          isMarking,
        ),
      },
    );
  }

  Widget _buildNotFoundState() {
    return const EmptyDashboardWidget(
      icon: Icons.event_busy_rounded,
      title: 'Session Not Found',
      message: "This session doesn't exist or may have been removed.",
    );
  }

  Widget _scrollableCenter(Widget child) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildContent(SessionRosterModel roster, bool isMarking) {
    final presentStudents = roster.presentList.where(_matchesSearch).toList();

    final absentStudents = roster.absentList.where(_matchesSearch).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.screenPaddingH,
        vertical: AppSizes.screenPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (roster.sessionActive) ...[
            _buildLiveBanner(),
            const SizedBox(height: AppSizes.lg),
          ],
          _buildSummaryCard(roster),
          const SizedBox(height: AppSizes.lg),
          AppSearchBar(
            controller: _searchController,
            hintText: 'Search student',
            onChanged: (value) {
              setState(() {
                _query = value.trim().toLowerCase();
              });
            },
          ),
          const SizedBox(height: AppSizes.lg),
          _buildPresentSection(presentStudents),
          const SizedBox(height: AppSizes.lg),
          _buildAbsentSection(absentStudents),
          if (_selectedStudents.isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            _buildManualAttendanceSection(isMarking),
          ],
          const SizedBox(height: AppSizes.lg),
          AppButton(
            label: 'Done',
            icon: Icons.check_circle_outline,
            onPressed: () => context.pop(),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }

  bool _matchesSearch(RosterEntryModel student) {
    if (_query.isEmpty) return true;

    final userName = student.userName.toLowerCase();
    final prn = (student.prn ?? '').toLowerCase();

    return userName.contains(_query) || prn.contains(_query);
  }

  Widget _buildLiveBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.sensors_rounded, color: AppColors.success, size: 18),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'This session is still live — counts may change.',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SessionRosterModel roster) {
    return SectionCard(
      title: 'Attendance Summary',
      showArrow: false,
      child: StatTileRow(
        tiles: [
          StatTile(
            icon: Icons.check_circle,
            label: 'Present',
            value: '${roster.presentCount}',
            color: AppColors.success,
          ),
          StatTile(
            icon: Icons.cancel,
            label: 'Absent',
            value: '${roster.absentCount}',
            color: AppColors.error,
          ),
          StatTile(
            icon: Icons.groups,
            label: 'Total',
            value: '${roster.totalStudents}',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPresentSection(List<RosterEntryModel> students) {
    return SectionCard(
      title: 'Present Students (${students.length})',
      showArrow: false,
      child: students.isEmpty
          ? _buildEmptyState(
              _query.isEmpty
                  ? 'No present students.'
                  : 'No matching present students.',
            )
          : Column(
              children: students
                  .map(
                    (student) => AttendanceStudentTile(
                      student: student,
                      trailing: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildAbsentSection(List<RosterEntryModel> students) {
    return SectionCard(
      title: 'Absent Students (${students.length})',
      showArrow: false,
      child: students.isEmpty
          ? _buildEmptyState(
              _query.isEmpty
                  ? 'No absent students.'
                  : 'No matching absent students.',
            )
          : Column(
              children: students
                  .map(
                    (student) => AttendanceStudentTile(
                      student: student,
                      showCheckbox: true,
                      isSelected: _selectedStudents.contains(student.studentId),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedStudents.add(student.studentId);
                          } else {
                            _selectedStudents.remove(student.studentId);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildManualAttendanceSection(bool isMarking) {
    return SectionCard(
      title: 'Manual Attendance',
      showArrow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${_selectedStudents.length} student(s) selected',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          if (isMarking) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSizes.md),
          ],
          AppButton(
            label: 'Mark Selected Present',
            icon: Icons.how_to_reg_rounded,
            onPressed: _showReasonDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}
