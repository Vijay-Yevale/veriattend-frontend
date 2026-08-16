import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/enums/weekday.dart';
import 'package:veriattend_app/core/model/user_model.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';

import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';
import 'package:veriattend_app/features/timetable/presentation/providers/timetable_provider.dart';

import 'package:veriattend_app/features/timetable/presentation/widgets/active_lecture_banner.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/teacher_timetable_header.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/timetable_body_widget.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/weekday_selector.dart';

class TeacherTimetableScreen extends ConsumerStatefulWidget {
  final String? teacherId;
  final String? teacherName;

  const TeacherTimetableScreen({super.key, this.teacherId, this.teacherName});

  @override
  ConsumerState<TeacherTimetableScreen> createState() =>
      _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends ConsumerState<TeacherTimetableScreen>
    with WidgetsBindingObserver {
  WeekDay _selectedDay = WeekDayExtension.today;

  Timer? _tickTimer;

  bool get _isOwnTimetable => widget.teacherId == null;

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

  AuthAuthenticated? get _authState {
    final state = ref.watch(authProvider);

    if (state is AuthAuthenticated) {
      return state;
    }

    return null;
  }

  UserModel? get _user => _authState?.user;

  bool get _isHod => _user?.role == 'HOD';

  List<AppNavItem> get _navItems {
    if (_isHod) return HodNavItems.items;
    return TeacherNavItems.items;
  }

  String get _currentRoute {
    if (_isHod) return AppRoutes.hodTimetable;
    return AppRoutes.myTimetableRoute;
  }

  TeacherTimetableParams get _params => TeacherTimetableParams(
    teacherId: widget.teacherId,
    day: _selectedDay.apiValue,
  );

  Future<void> _refresh() async {
    ref.invalidate(teacherTimetableProvider(_params));

    await ref.read(teacherTimetableProvider(_params).future);
  }

  String _resolvedDisplayName(List<TimetableSlotModel> slots) {
    if (_isOwnTimetable) {
      final name = _user?.userName;

      if (name != null && name.trim().isNotEmpty) {
        return name;
      }

      final email = _user?.email;

      if (email != null && email.trim().isNotEmpty) {
        return email;
      }

      return 'My Timetable';
    }

    final passedName = widget.teacherName;

    if (passedName != null && passedName.trim().isNotEmpty) {
      return passedName;
    }

    if (slots.isNotEmpty) {
      return slots.first.teacher.userName;
    }

    return 'Teacher Timetable';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_authState == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: .35),
                ),
              ),
              child: Text(
                'Unable to load user information.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final timetableAsync = ref.watch(teacherTimetableProvider(_params));

    if (timetableAsync.hasError) {
      return AppScaffold(
        title: 'Teacher Timetable',
        navItems: _navItems,
        currentRoute: _currentRoute,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: AppErrorWidget(
              message: timetableAsync.error.toString(),
              onRetry: _refresh,
            ),
          ),
        ),
      );
    }

    final slots = timetableAsync.value ?? const <TimetableSlotModel>[];

    final timetableLoading = timetableAsync.isLoading;

    final isViewingToday = _selectedDay == WeekDayExtension.today;

    String? nowApiTime;

    if (isViewingToday) {
      final now = TimeOfDay.now();

      nowApiTime =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
    }

    TimetableSlotModel? activeSlot;

    if (nowApiTime != null) {
      final currentTime = nowApiTime;

      activeSlot = slots.cast<TimetableSlotModel?>().firstWhere(
        (slot) =>
            slot!.startTime.compareTo(currentTime) <= 0 &&
            slot.endTime.compareTo(currentTime) >= 0,
        orElse: () => null,
      );
    }

    final completedSlotIds = <String>{
      if (nowApiTime != null)
        for (final slot in slots)
          if (slot.endTime.compareTo(nowApiTime) <= 0) slot.timetableId,
    };

    return AppScaffold(
      title: 'Teacher Timetable',
      navItems: _navItems,
      currentRoute: _currentRoute,
      body: RefreshIndicator(
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPaddingH,
            AppSizes.screenPaddingV,
            AppSizes.screenPaddingH,
            AppSizes.xxl,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TeacherTimetableHeader(displayName: _resolvedDisplayName(slots)),

            const SizedBox(height: AppSizes.lg),

            ActiveLectureBanner(
              activeSlot: activeSlot,
              infoText: activeSlot?.classInfo.className,
              infoIcon: Icons.groups_outlined,
            ),

            const SizedBox(height: AppSizes.xs),

            WeekdaySelector(
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                if (day == _selectedDay) return;

                setState(() => _selectedDay = day);
              },
            ),

            const SizedBox(height: AppSizes.lg),

            if (timetableLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Loading timetable...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (slots.isEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSizes.xxl,
                  bottom: AppSizes.xxl,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: .4),
                    ),
                  ),
                  child: const EmptyDashboardWidget(
                    title: 'No timetable available',
                    message:
                        'Timetable slots will appear here once they are added for this day.',
                  ),
                ),
              )
            else
              TimetableBody(
                slots: slots,
                canManage: false,

                /// Teacher timetable always shows the class name.
                infoTextBuilder: (slot) => slot.classInfo.className,
                infoIconBuilder: (_) => Icons.groups_outlined,

                activeSlotId: activeSlot?.timetableId,
                completedSlotIds: completedSlotIds,
              ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}
