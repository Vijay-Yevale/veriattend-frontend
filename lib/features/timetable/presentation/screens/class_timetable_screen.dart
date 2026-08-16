import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/enums/weekday.dart';
import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';

import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';

import 'package:veriattend_app/features/information/presentation/providers/class_provider.dart';

import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';

import 'package:veriattend_app/features/timetable/presentation/providers/timetable_action_provider.dart';
import 'package:veriattend_app/features/timetable/presentation/providers/timetable_provider.dart';

import 'package:veriattend_app/features/timetable/presentation/screens/timetable_management_screen.dart';

import 'package:veriattend_app/features/timetable/presentation/widgets/active_lecture_banner.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/class_timetable_header.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/timetable_body_widget.dart';
import 'package:veriattend_app/features/timetable/presentation/widgets/weekday_selector.dart';

class ClassTimetableScreen extends ConsumerStatefulWidget {
  final String? classId;

  const ClassTimetableScreen({super.key, this.classId});

  @override
  ConsumerState<ClassTimetableScreen> createState() =>
      _ClassTimetableScreenState();
}

class _ClassTimetableScreenState extends ConsumerState<ClassTimetableScreen>
    with WidgetsBindingObserver {
  WeekDay _selectedDay = WeekDayExtension.today;

  ProviderSubscription<ActionState>? _actionSubscription;

  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _actionSubscription = ref.listenManual<ActionState>(
      timetableActionProvider,
      (previous, next) {
        if (!mounted) return;

        handleActionState(
          context: context,
          state: next,
          onReset: () => ref.read(timetableActionProvider.notifier).reset(),
          onSuccess: () => _refresh(),
        );
      },
    );

    // Local clock tick — recomputes which slot is "active" every 30s
    // from data already in memory. No network call.
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _actionSubscription?.close();
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

  bool get _isStudent => _user?.role == 'STUDENT';

  bool get _isTeacher => _user?.role == 'TEACHER';

  bool get _isHod => _user?.role == 'HOD';

  bool get _isSuperAdmin => _user?.role == 'SUPER_ADMIN';

  bool get _canManage => _isHod;

  List<AppNavItem> get _navItems {
    if (_isHod) return HodNavItems.items;
    if (_isTeacher) return TeacherNavItems.items;
    return StudentNavItems.items;
  }

  String get _currentRoute {
    if (_isHod) return AppRoutes.hodTimetable;

    return AppRoutes.myTimetableRoute;
  }

  String? get _resolvedClassId => widget.classId;

  Future<void> _refresh() async {
    ref.invalidate(
      classTimetableProvider(
        ClassTimetableParams(
          classId: _resolvedClassId,
          day: _selectedDay.apiValue,
        ),
      ),
    );

    if (_resolvedClassId != null) {
      ref.invalidate(classDetailProvider(_resolvedClassId!));
    }

    await Future.wait([
      ref.read(
        classTimetableProvider(
          ClassTimetableParams(
            classId: _resolvedClassId,
            day: _selectedDay.apiValue,
          ),
        ).future,
      ),
      if (_resolvedClassId != null)
        ref.read(classDetailProvider(_resolvedClassId!).future),
    ]);
  }

  Future<void> _openManageScreen(String classId, [TimetableSlotModel? slot]) {
    return context.push<bool>(
      AppRoutes.timetableManageRoute,
      extra: TimetableManageArgs(classId: classId, slot: slot),
    );
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
            child: Text(
              'Unable to load user information.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    if (_isTeacher && widget.classId == null) {
      return AppScaffold(
        title: 'Class Timetable',
        navItems: _navItems,
        currentRoute: _currentRoute,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: EmptyDashboardWidget(
              title: 'No class selected',
              message: 'Select a class to view its timetable.',
            ),
          ),
        ),
      );
    }

    final timetableAsync = ref.watch(
      classTimetableProvider(
        ClassTimetableParams(
          classId: _resolvedClassId,
          day: _selectedDay.apiValue,
        ),
      ),
    );

    final AsyncValue<ClassModel>? classAsync = widget.classId != null
        ? ref.watch(classDetailProvider(widget.classId!))
        : null;

    final ClassModel? ownClass = _user?.classInfo;

    final classData = widget.classId != null ? classAsync?.value : ownClass;

    if (widget.classId != null && (classAsync?.hasError ?? false)) {
      return AppScaffold(
        title: 'Class Timetable',
        navItems: _navItems,
        currentRoute: _currentRoute,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: AppErrorWidget(
              message:
                  classAsync?.error.toString() ??
                  'Unable to load class information.',
              onRetry: _refresh,
            ),
          ),
        ),
      );
    }

    final headerLoading =
        widget.classId != null &&
        classData == null &&
        (classAsync?.isLoading ?? false);

    if (headerLoading) {
      return AppScaffold(
        title: 'Class Timetable',
        navItems: _navItems,
        currentRoute: _currentRoute,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    if (classData == null) {
      final title = _isStudent
          ? 'No class assigned yet'
          : 'Selected class not found';

      final message = _isStudent
          ? 'Please contact your department to get assigned to a class.'
          : 'This class may have been removed or the link is incorrect.';

      return AppScaffold(
        title: 'Class Timetable',
        navItems: _navItems,
        currentRoute: _currentRoute,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: EmptyDashboardWidget(title: title, message: message),
          ),
        ),
      );
    }

    if (timetableAsync.hasError) {
      return AppScaffold(
        title: 'Class Timetable',
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

    // Active slot computed locally from the day's already-loaded slots —
    // no dedicated backend call, same approach as TeacherTimetableScreen.
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
      title: 'Class Timetable',
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
            ClassTimetableHeader(
              className: classData.className,
              classTeacherName:
                  classData.classTeacher?.userName ?? 'Not Assigned',
              semester: classData.semester,
            ),

            const SizedBox(height: AppSizes.lg),

            ActiveLectureBanner(activeSlot: activeSlot),

            const SizedBox(height: AppSizes.xs),

            WeekdaySelector(
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                if (day == _selectedDay) return;

                setState(() => _selectedDay = day);
              },
            ),

            const SizedBox(height: AppSizes.lg),

            // Add Slot (HOD only)
            if (_canManage) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    onTap: () => _openManageScreen(classData.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: AppSizes.iconSm,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            'Add Slot',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),
            ],

            if (timetableLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
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
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: .45),
                      ),
                    ),
                    child: EmptyDashboardWidget(
                      title: 'No timetable available',
                      message: _canManage
                          ? 'Tap "Add Slot" to schedule a lecture for this day.'
                          : 'Timetable slots will appear here once they are added for this day.',
                    ),
                  ),
                ),
              )
            else
              TimetableBody(
                slots: slots,

                // Only HOD can manage timetable
                canManage: _canManage,

                /// Class timetable always shows teacher name
                infoTextBuilder: (slot) => slot.teacher.userName,
                infoIconBuilder: (_) => Icons.person_outline_rounded,

                activeSlotId: activeSlot?.timetableId,
                completedSlotIds: completedSlotIds,

                onEdit: !_canManage
                    ? null
                    : (slot) => _openManageScreen(classData.id, slot),

                onDelete: !_canManage
                    ? null
                    : (slot) async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusLg,
                              ),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.error.withValues(
                                      alpha: .10,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMd,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: colorScheme.error,
                                    size: AppSizes.iconMd,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                const Expanded(
                                  child: Text('Delete Timetable Slot'),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSizes.md),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest
                                        .withValues(alpha: .45),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMd,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        slot.subject.subjectName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: AppSizes.xs),
                                      Text(
                                        '${slot.startTime} - ${slot.endTime}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSizes.md),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: AppSizes.iconSm,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    Expanded(
                                      child: Text(
                                        'This action cannot be undone.',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colorScheme.error,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton.icon(
                                onPressed: () => Navigator.pop(context, true),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: AppSizes.iconSm,
                                ),
                                label: const Text('Delete'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.onError,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMd,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete != true || !mounted) {
                          return;
                        }

                        await ref
                            .read(timetableActionProvider.notifier)
                            .deleteTimetableSlot(timetableId: slot.timetableId);
                      },
              ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}
