import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/utils/time_format.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/info_row.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';

import 'package:veriattend_app/features/attendance/presentation/providers/attendance_action_provider.dart';
import 'package:veriattend_app/features/attendance/presentation/widgets/live_attendance_view.dart';
import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';

class TeacherSessionScreen extends ConsumerStatefulWidget {
  final TimetableSlotModel slot;

  const TeacherSessionScreen({super.key, required this.slot});

  @override
  ConsumerState<TeacherSessionScreen> createState() =>
      _TeacherSessionScreenState();
}

class _TeacherSessionScreenState extends ConsumerState<TeacherSessionScreen> {
  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceActionProvider);

    ref.listen<AttendanceState>(attendanceActionProvider, (previous, next) {
      if (next is AttendanceReview) {
        final sessionId = next.session.sessionId;

        context.push(AppRoutes.attendanceReview(sessionId));

        ref.read(attendanceActionProvider.notifier).resetAttendance();
      }
    });

    return AppScaffold(
      title: 'Live Attendance',
      currentRoute: AppRoutes.teacher,
      navItems: TeacherNavItems.items,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
          vertical: AppSizes.screenPaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (attendanceState is! AttendanceLive &&
                attendanceState is! AttendanceReview) ...[
              _buildLectureCard(),

              const SizedBox(height: AppSizes.lg),
            ],

            _buildAttendanceSection(attendanceState),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SectionCard(
      title: 'Current Lecture',
      showArrow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Text(
            widget.slot.subject.subjectName,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          // Lecture status
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm + 2,
              vertical: AppSizes.xs + 1,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Scheduled Lecture',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          InfoRow(
            icon: Icons.groups_rounded,
            label: 'Class',
            value: widget.slot.classInfo.className,
          ),

          const SizedBox(height: AppSizes.md),

          InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Room',
            value: widget.slot.room,
          ),

          const SizedBox(height: AppSizes.md),

          InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Lecture Time',
            value:
                '${formatTime12Hr(widget.slot.startTime)} - '
                '${formatTime12Hr(widget.slot.endTime)}',
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Attendance',
      showArrow: false,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.how_to_reg_rounded,
              color: colorScheme.primary,
              size: AppSizes.iconLg,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          Text(
            'Ready to take attendance?',
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.xs),

          Text(
            'Start attendance to enable student check-in.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          AppButton(
            label: 'Start Attendance',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              ref.read(attendanceActionProvider.notifier).startAttendance();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(AttendanceState state) {
    switch (state) {
      case AttendanceInitial():
        return _buildAttendanceCard();

      case AttendanceStarting():
        return SectionCard(
          title: 'Preparing Session',
          showArrow: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
            child: Column(
              children: [
                const AppLoader(),

                const SizedBox(height: AppSizes.md),

                Text(
                  'Setting up attendance...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );

      case AttendanceError():
        return SectionCard(
          title: 'Attendance Error',
          showArrow: false,
          child: AppErrorWidget(
            message: state.message,
            onRetry: () {
              ref.read(attendanceActionProvider.notifier).startAttendance();
            },
          ),
        );

      case AttendanceLive():
        return AttendanceLiveView(state: state);

      case AttendanceReview():
        return SectionCard(
          title: 'Session Ended',
          showArrow: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
            child: Column(
              children: [
                const AppLoader(),

                const SizedBox(height: AppSizes.md),

                Text(
                  'Opening session review...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
