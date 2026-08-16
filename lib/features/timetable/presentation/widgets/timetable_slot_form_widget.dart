// lib/features/timetable/presentation/widgets/timetable_slot_form_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/enums/weekday.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/core/utils/snackbar.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/app_drop_down.dart';
import 'package:veriattend_app/core/widgets/app_text_field.dart';
import 'package:veriattend_app/core/widgets/form_section.dart';

import 'package:veriattend_app/features/hod/domain/model/subject_model.dart';
import 'package:veriattend_app/features/hod/domain/model/teacher_assignment_model.dart';
import 'package:veriattend_app/features/hod/presentation/providers/manage_provider.dart';

import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';
import 'package:veriattend_app/features/timetable/presentation/providers/timetable_action_provider.dart';

class TimetableSlotFormWidget extends ConsumerStatefulWidget {
  final String classId;

  final List<SubjectModel> subjects;

  final TimetableSlotModel? slot;

  final VoidCallback? onCompleted;

  const TimetableSlotFormWidget({
    super.key,
    required this.classId,
    required this.subjects,
    this.slot,
    this.onCompleted,
  });

  @override
  ConsumerState<TimetableSlotFormWidget> createState() =>
      _TimetableSlotFormWidgetState();
}

class _TimetableSlotFormWidgetState
    extends ConsumerState<TimetableSlotFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _roomController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;

  ProviderSubscription<ActionState>? _actionSubscription;

  SubjectModel? _selectedSubject;
  WeekDay? _selectedWeekDay;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool get _isEdit => widget.slot != null;

  bool get _isLoading => ref.watch(timetableActionProvider) is ActionLoading;

  bool get _isTimeRangeValid {
    if (_startTime == null || _endTime == null) return false;

    final start = _startTime!.hour * 60 + _startTime!.minute;
    final end = _endTime!.hour * 60 + _endTime!.minute;

    return end > start;
  }

  TeacherAssignmentModel? _resolvedAssignment(
    List<TeacherAssignmentModel> assignments,
  ) {
    final subject = _selectedSubject;
    if (subject == null) return null;

    for (final assignment in assignments) {
      if (!assignment.isActive) continue;
      if (assignment.classInfo.classId != widget.classId) continue;
      if (assignment.subject.subjectId != subject.subjectId) continue;
      return assignment;
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    _roomController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();

    _initializeForm();

    _actionSubscription = ref.listenManual<ActionState>(
      timetableActionProvider,
      (previous, next) {
        handleActionState(
          context: context,
          state: next,
          onSuccess: () {
            if (!_isEdit) {
              _clearForm();
            }

            widget.onCompleted?.call();
          },
          onReset: _resetActionState,
        );
      },
    );
  }

  @override
  void dispose() {
    _actionSubscription?.close();

    _roomController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();

    super.dispose();
  }

  void _initializeForm() {
    if (!_isEdit) return;

    final slot = widget.slot!;

    _roomController.text = slot.room;
    _selectedWeekDay = slot.weekDay;

    _selectedSubject = widget.subjects.cast<SubjectModel?>().firstWhere(
      (subject) => subject?.subjectId == slot.subject.subjectId,
      orElse: () => null,
    );

    _startTime = _parseTime(slot.startTime);
    _endTime = _parseTime(slot.endTime);

    _startTimeController.text = _formatDisplayTime(_startTime!);
    _endTimeController.text = _formatDisplayTime(_endTime!);
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatDisplayTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  String _formatApiTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = (isStart ? _startTime : _endTime) ?? TimeOfDay.now();

    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startTime = picked;
        _startTimeController.text = _formatDisplayTime(picked);
      } else {
        _endTime = picked;
        _endTimeController.text = _formatDisplayTime(picked);
      }
    });
  }

  void _clearForm() {
    setState(() {
      _selectedSubject = null;
      _selectedWeekDay = null;
      _startTime = null;
      _endTime = null;

      _roomController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
    });
  }

  void _resetActionState() {
    ref.read(timetableActionProvider.notifier).reset();
  }

  void _submit(TeacherAssignmentModel? assignment) {
    if (!_formKey.currentState!.validate()) return;

    if (assignment == null) {
      showErrorSnackBar(
        context,
        'No teacher is assigned to this subject for this class yet.',
      );
      return;
    }

    if (!_isTimeRangeValid) {
      showErrorSnackBar(context, 'End time must be after start time.');
      return;
    }

    final notifier = ref.read(timetableActionProvider.notifier);

    if (_isEdit) {
      notifier.updateTimetableSlot(
        timetableId: widget.slot!.timetableId,
        updates: {
          'teacherId': assignment.teacher.teacherId,
          'subjectId': _selectedSubject!.subjectId,
          'classId': widget.classId,
          'room': _roomController.text.trim(),
          'weekDay': _selectedWeekDay!.apiValue,
          'startTime': _formatApiTime(_startTime!),
          'endTime': _formatApiTime(_endTime!),
        },
      );
    } else {
      notifier.createTimetableSlot(
        teacherId: assignment.teacher.teacherId,
        subjectId: _selectedSubject!.subjectId,
        classId: widget.classId,
        room: _roomController.text.trim(),
        weekDay: _selectedWeekDay!.apiValue,
        startTime: _formatApiTime(_startTime!),
        endTime: _formatApiTime(_endTime!),
      );
    }
  }

  Widget _teacherField(AsyncValue<List<TeacherAssignmentModel>> async) {
    return async.when(
      loading: () => const _TeacherFieldShell(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),

      error: (error, _) => _TeacherFieldShell(
        isError: true,
        child: Text(
          'Failed to load teacher assignments.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),
      ),

      data: (assignments) {
        final assignment = _resolvedAssignment(assignments);

        if (_selectedSubject == null) {
          return const _TeacherFieldShell(
            child: Text('Select a subject first'),
          );
        }

        if (assignment == null) {
          return _TeacherFieldShell(
            isError: true,
            child: Text(
              'No teacher assigned to this subject for this class.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          );
        }

        return _TeacherFieldShell(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Teacher',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assignment.teacher.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                size: AppSizes.iconMd,
                color: AppColors.success,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final assignmentsAsync = ref.watch(teacherAssignmentsProvider);

    final assignment = assignmentsAsync.maybeWhen(
      data: _resolvedAssignment,
      orElse: () => null,
    );

    return Form(
      key: _formKey,
      child: FormSection(
        title: _isEdit ? 'Update Timetable Slot' : 'Create Timetable Slot',
        icon: _isEdit
            ? Icons.edit_calendar_outlined
            : Icons.add_circle_outline_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: theme.brightness == Brightness.dark ? .10 : .055,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: .14),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      _isEdit
                          ? Icons.edit_calendar_outlined
                          : Icons.calendar_month_outlined,
                      color: colorScheme.primary,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit
                              ? 'Edit schedule details'
                              : 'Add a class to the timetable',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          _isEdit
                              ? 'Update the assigned subject, timing, room or weekday.'
                              : 'Select the subject and schedule details for this class.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: .62),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            AppDropdown<SubjectModel>(
              value: _selectedSubject,
              labelText: 'Subject',
              hintText: 'Select subject',
              prefixIcon: Icons.menu_book_outlined,
              enabled: !_isLoading,
              items: widget.subjects
                  .map(
                    (subject) => DropdownMenuItem<SubjectModel>(
                      value: subject,
                      child: Text(
                        '${subject.subjectCode} • ${subject.subjectName}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (subject) {
                setState(() => _selectedSubject = subject);
              },
              validator: (subject) =>
                  subject == null ? 'Please select a subject' : null,
            ),

            const SizedBox(height: AppSizes.md),

            Text(
              'Teacher',
              style: AppTextStyles.labelLarge.copyWith(
                color: colorScheme.onSurface.withValues(alpha: .72),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppSizes.xs),

            _teacherField(assignmentsAsync),

            const SizedBox(height: AppSizes.md),

            AppDropdown<WeekDay>(
              value: _selectedWeekDay,
              labelText: 'Week Day',
              hintText: 'Select weekday',
              prefixIcon: Icons.calendar_today_outlined,
              enabled: !_isLoading,
              items: WeekDay.values
                  .map(
                    (day) =>
                        DropdownMenuItem(value: day, child: Text(day.fullName)),
                  )
                  .toList(),
              onChanged: (day) {
                setState(() => _selectedWeekDay = day);
              },
              validator: (day) =>
                  day == null ? 'Please select a weekday' : null,
            ),

            const SizedBox(height: AppSizes.md),

            AppTextField(
              controller: _roomController,
              labelText: 'Room',
              hintText: 'Enter room number',
              prefixIcon: Icons.meeting_room_outlined,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Room is required';
                }

                return null;
              },
            ),

            const SizedBox(height: AppSizes.lg),

            Text(
              'Class Timing',
              style: AppTextStyles.titleMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSizes.xs),

            Text(
              'Set when this class starts and ends.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: .58),
              ),
            ),

            const SizedBox(height: AppSizes.md),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _startTimeController,
                    labelText: 'Start Time',
                    hintText: 'Select',
                    prefixIcon: Icons.schedule_outlined,
                    readOnly: true,
                    enabled: !_isLoading,
                    onTap: () => _pickTime(isStart: true),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),

                const SizedBox(width: AppSizes.md),

                Expanded(
                  child: AppTextField(
                    controller: _endTimeController,
                    labelText: 'End Time',
                    hintText: 'Select',
                    prefixIcon: Icons.schedule_outlined,
                    readOnly: true,
                    enabled: !_isLoading,
                    onTap: () => _pickTime(isStart: false),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),

            if (_startTime != null &&
                _endTime != null &&
                !_isTimeRangeValid) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: .18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: AppSizes.iconSm,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'End time must be after start time.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSizes.xl),

            AppButton(
              label: _isEdit ? 'Update Timetable' : 'Create Timetable',
              icon: _isEdit ? Icons.save_outlined : Icons.add,
              isLoading: _isLoading,
              onPressed: () => _submit(assignment),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherFieldShell extends StatelessWidget {
  final Widget child;
  final bool isError;

  const _TeacherFieldShell({required this.child, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = isError
        ? AppColors.error
        : colorScheme.outline.withValues(alpha: .55);

    final backgroundColor = isError
        ? AppColors.error.withValues(
            alpha: theme.brightness == Brightness.dark ? .08 : .045,
          )
        : colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
        border: Border.all(color: borderColor, width: isError ? 1.2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isError
                  ? AppColors.error.withValues(alpha: .10)
                  : AppColors.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              isError
                  ? Icons.person_off_outlined
                  : Icons.person_outline_rounded,
              size: AppSizes.iconMd,
              color: isError ? AppColors.error : AppColors.primary,
            ),
          ),

          const SizedBox(width: AppSizes.md),

          Expanded(child: child),
        ],
      ),
    );
  }
}
