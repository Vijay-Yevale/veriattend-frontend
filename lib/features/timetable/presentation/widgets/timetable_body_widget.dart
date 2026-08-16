import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/features/timetable/domain/model/timetable_slot_model.dart';

import 'timetable_slot_card.dart';

class TimetableBody extends StatelessWidget {
  final List<TimetableSlotModel> slots;

  final bool canManage;

  final String Function(TimetableSlotModel slot) infoTextBuilder;

  final IconData Function(TimetableSlotModel slot) infoIconBuilder;

  final ValueChanged<TimetableSlotModel>? onEdit;
  final ValueChanged<TimetableSlotModel>? onDelete;

  final String? activeSlotId;

  final Set<String> completedSlotIds;

  const TimetableBody({
    super.key,
    required this.slots,
    required this.infoTextBuilder,
    required this.infoIconBuilder,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.activeSlotId,
    this.completedSlotIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: slots.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        final slot = slots[index];

        final isLive = activeSlotId != null && slot.timetableId == activeSlotId;

        final isCompleted =
            !isLive && completedSlotIds.contains(slot.timetableId);

        return TimetableSlotCard(
          startTime: slot.startTime,
          endTime: slot.endTime,
          subjectName: slot.subject.subjectName,
          infoText: infoTextBuilder(slot),
          infoIcon: infoIconBuilder(slot),
          room: slot.room,
          canManage: canManage,
          isLive: isLive,
          isCompleted: isCompleted,
          onEdit: onEdit == null ? null : () => onEdit!(slot),
          onDelete: onDelete == null ? null : () => onDelete!(slot),
        );
      },
    );
  }
}
