// lib/features/attendance/presentation/screens/teacher_session_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/errors/failures.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/utils/time_format.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/quick_action_card.dart';

import 'package:veriattend_app/features/attendance/domain/model/teacher_session_history_model.dart';
import 'package:veriattend_app/features/attendance/presentation/providers/teacher_session_history_provider.dart';

class TeacherSessionHistoryScreen extends ConsumerStatefulWidget {
  const TeacherSessionHistoryScreen({super.key});

  @override
  ConsumerState<TeacherSessionHistoryScreen> createState() =>
      _TeacherSessionHistoryScreenState();
}

class _TeacherSessionHistoryScreenState
    extends ConsumerState<TeacherSessionHistoryScreen> {
  bool _todayOnly = true;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(teacherSessionHistoryProvider(_todayOnly));

    return AppScaffold(
      title: 'Session History',
      currentRoute: AppRoutes.teacherSessionHistoryRoute,
      navItems: TeacherNavItems.items,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
          vertical: AppSizes.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterToggle(),

            const SizedBox(height: AppSizes.lg),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  try {
                    await ref.refresh(
                      teacherSessionHistoryProvider(_todayOnly).future,
                    );
                  } catch (_) {
                    // Failure state is already surfaced below.
                  }
                },
                child: sessionsAsync.when(
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildList(sessions);
                  },
                  loading: () => const Center(child: AppLoader()),
                  error: (error, _) => _buildErrorState(error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.65 : 0.55,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.55)),
      ),
      padding: const EdgeInsets.all(3),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            label: Text('Today'),
            icon: Icon(Icons.today_rounded, size: AppSizes.iconSm + 2),
          ),
          ButtonSegment(
            value: false,
            label: Text('All'),
            icon: Icon(Icons.history_rounded, size: AppSizes.iconSm + 2),
          ),
        ],
        selected: {_todayOnly},
        onSelectionChanged: (selection) {
          setState(() => _todayOnly = selection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurfaceVariant,
          selectedBackgroundColor: colorScheme.primary,
          selectedForegroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          textStyle: AppTextStyles.labelMedium,
        ),
      ),
    );
  }

  Widget _buildList(List<TeacherSessionHistoryModel> sessions) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) => _buildSessionTile(sessions[index]),
    );
  }

  Widget _buildSessionTile(TeacherSessionHistoryModel session) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return QuickActionCard(
      title: '${session.subject.subjectName} • ${session.classInfo.className}',
      subtitle:
          '${session.weekDay}, ${formatTime12Hr(session.startTime)} - '
          '${formatTime12Hr(session.endTime)}  •  '
          '${_formatDate(session.createdAt)}',
      icon: session.isActive
          ? Icons.sensors_rounded
          : Icons.event_available_rounded,
      trailing: session.isActive
          ? _buildLiveBadge()
          : Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: AppSizes.iconMd,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
      onTap: () {
        context.push(AppRoutes.attendanceReview(session.sessionId));
      },
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.success.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    if (error is NotFoundFailure) {
      return _buildEmptyState();
    }

    return _scrollableCenter(
      AppErrorWidget(
        message: error is Failure ? error.message : error.toString(),
        onRetry: () =>
            ref.invalidate(teacherSessionHistoryProvider(_todayOnly)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return _scrollableCenter(
      EmptyDashboardWidget(
        icon: Icons.event_busy_rounded,
        title: _todayOnly ? 'No Lecture Conducted Today' : 'No Session History',
        message: _todayOnly
            ? "You haven't started an attendance session today yet."
            : "You haven't conducted any attendance sessions yet.",
      ),
    );
  }

  Widget _scrollableCenter(Widget child) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
        child: child,
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${dt.day.toString().padLeft(2, '0')} '
      '${months[dt.month - 1]} ${dt.year}';
}
