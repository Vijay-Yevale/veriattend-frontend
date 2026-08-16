import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/enums/weekday.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/greeting_section.dart';

import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:veriattend_app/features/teacher/domain/model/teacher_class_summary_model.dart';
import 'package:veriattend_app/features/teacher/presentation/providers/teacher_provider.dart';
import 'package:veriattend_app/features/teacher/presentation/widgets/teacher_class_list_widget.dart';

import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';
import 'package:veriattend_app/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/active_lecture_banner.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/timetable_body_widget.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen>
    with WidgetsBindingObserver {
  Timer? _tickTimer;

  TeacherTimetableParams get _todayParams =>
      TeacherTimetableParams(day: WeekDayExtension.today.apiValue);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    _refresh().catchError((_) {});
  }

  Future<void> _refresh() async {
    ref.invalidate(teacherTimetableProvider(_todayParams));
    ref.invalidate(myClassesProvider);

    await Future.wait([
      ref.read(teacherTimetableProvider(_todayParams).future),
      ref.read(myClassesProvider.future),
    ]);
  }

  String _nowApiTime() {
    final now = TimeOfDay.now();

    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  void _openSession(TimetableSlotModel slot) {
    context.push(AppRoutes.teacherSessionRoute, extra: slot);
  }

  void _openClassAnalytics(TeacherClassSummaryModel classItem) {
    if (classItem.subjects.length == 1) {
      final subject = classItem.subjects.first;

      context.push(
        AppRoutes.subjectDashboard(classItem.classId, subject.subjectId),
        extra: subject.subjectName,
      );

      return;
    }

    context.push(AppRoutes.classDashboard(classItem.classId));
  }

  String _greetingSubtitle({
    required bool loading,
    required TimetableSlotModel? activeSlot,
    required int upcomingCount,
  }) {
    if (loading) return 'Loading your schedule…';

    if (activeSlot != null) {
      return 'You have an ongoing lecture right now';
    }

    if (upcomingCount > 0) {
      return upcomingCount == 1
          ? 'You have 1 lecture today'
          : 'You have $upcomingCount lectures today';
    }

    return 'No lectures scheduled for today';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final userName = switch (authState) {
      AuthAuthenticated(user: final user) => user.userName,
      _ => 'Teacher',
    };

    final timetableAsync = ref.watch(teacherTimetableProvider(_todayParams));

    final myClassesAsync = ref.watch(myClassesProvider);

    final slots = timetableAsync.value ?? const <TimetableSlotModel>[];

    final timetableLoading = timetableAsync.isLoading;
    final currentTime = _nowApiTime();

    TimetableSlotModel? activeSlot;

    if (slots.isNotEmpty) {
      activeSlot = slots.cast<TimetableSlotModel?>().firstWhere(
        (slot) =>
            slot!.startTime.compareTo(currentTime) <= 0 &&
            slot.endTime.compareTo(currentTime) > 0,
        orElse: () => null,
      );
    }

    final upcomingSlots = slots
        .where((slot) => slot.startTime.compareTo(currentTime) > 0)
        .toList();

    return AppScaffold(
      showAppBar: false,
      navItems: TeacherNavItems.items,
      currentRoute: AppRoutes.teacher,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
            vertical: AppSizes.screenPaddingV,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            GreetingSection(
              userName: userName,
              subtitle: _greetingSubtitle(
                loading: timetableLoading,
                activeSlot: activeSlot,
                upcomingCount: upcomingSlots.length,
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            if (timetableAsync.hasError)
              AppErrorWidget(
                message: timetableAsync.error.toString(),
                onRetry: _refresh,
              )
            else if (timetableLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (slots.isEmpty)
              const EmptyDashboardWidget(
                title: 'No lectures today',
                message: 'Nothing on your timetable for today.',
                icon: Icons.event_available_outlined,
              )
            else ...[
              if (activeSlot != null)
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    onTap: () => _openSession(activeSlot!),
                    child: ActiveLectureBanner(
                      activeSlot: activeSlot,
                      infoText: activeSlot.classInfo.className,
                      infoIcon: Icons.groups_outlined,
                    ),
                  ),
                ),
              const SizedBox(height: AppSizes.lg),
              _SectionHeader(
                title: 'Upcoming Today',
                icon: Icons.schedule_outlined,
              ),
              const SizedBox(height: AppSizes.md),
              if (upcomingSlots.isEmpty)
                _NoUpcomingLectures(
                  message: activeSlot != null
                      ? 'No more lectures after this one.'
                      : 'No more lectures today.',
                )
              else
                TimetableBody(
                  slots: upcomingSlots,
                  infoTextBuilder: (slot) => slot.classInfo.className,
                  infoIconBuilder: (_) => Icons.groups_outlined,
                ),
            ],
            const SizedBox(height: AppSizes.xl),
            _SectionHeader(
              title: 'My Classes',
              icon: Icons.groups_outlined,
              trailing: myClassesAsync.value?.isNotEmpty ?? false
                  ? '${myClassesAsync.value!.length} total'
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            _MyClassesSection(
              classesAsync: myClassesAsync,
              onRetry: _refresh,
              onTapClass: _openClassAnalytics,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, size: AppSizes.iconMd, color: colorScheme.primary),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.65),
              ),
            ),
            child: Text(
              trailing!,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _NoUpcomingLectures extends StatelessWidget {
  final String message;

  const _NoUpcomingLectures({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_outlined,
              color: colorScheme.primary,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyClassesSection extends StatelessWidget {
  final AsyncValue<List<TeacherClassSummaryModel>> classesAsync;
  final VoidCallback onRetry;
  final ValueChanged<TeacherClassSummaryModel> onTapClass;

  const _MyClassesSection({
    required this.classesAsync,
    required this.onRetry,
    required this.onTapClass,
  });

  @override
  Widget build(BuildContext context) {
    if (classesAsync.hasError) {
      return AppErrorWidget(
        message: classesAsync.error.toString(),
        onRetry: onRetry,
      );
    }

    if (classesAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final classes = classesAsync.value ?? const <TeacherClassSummaryModel>[];

    if (classes.isEmpty) {
      return const EmptyDashboardWidget(
        title: 'No classes yet',
        message: 'You are not assigned to any class or subject.',
        icon: Icons.class_outlined,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < classes.length; i++) ...[
          TeacherClassListItem(
            className: classes[i].className,
            isClassTeacher: classes[i].isClassTeacher,
            subjectNames: classes[i].subjects
                .map((s) => s.subjectName)
                .toList(),
            onTap: () => onTapClass(classes[i]),
          ),
          if (i != classes.length - 1) const SizedBox(height: AppSizes.mm),
        ],
      ],
    );
  }
}
