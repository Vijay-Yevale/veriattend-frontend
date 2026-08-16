import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/enums/weekday.dart';

class WeekdaySelector extends StatefulWidget {
  final WeekDay selectedDay;
  final ValueChanged<WeekDay> onDaySelected;

  const WeekdaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  final Map<WeekDay, GlobalKey> _dayKeys = {
    for (final day in WeekDay.values) day: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  @override
  void didUpdateWidget(covariant WeekdaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDay != widget.selectedDay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDay();
      });
    }
  }

  void _scrollToSelectedDay() {
    final key = _dayKeys[widget.selectedDay];

    if (key?.currentContext == null) return;

    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = WeekDay.values;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == widget.selectedDay;

          return Material(
            key: _dayKeys[day],
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              onTap: () => widget.onDaySelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: .65),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: .16),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: AppSizes.iconSm,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppSizes.xs),
                    ],
                    Text(
                      day.shortName,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// // lib/features/timetable/presentation/widgets/weekday_selector.dart

// import 'package:flutter/material.dart';

// import 'package:veriattend_app/core/constants/app_sizes.dart';
// import 'package:veriattend_app/core/constants/app_text_styles.dart';
// import 'package:veriattend_app/core/enums/weekday.dart';

// class WeekdaySelector extends StatelessWidget {
//   final WeekDay selectedDay;
//   final ValueChanged<WeekDay> onDaySelected;

//   const WeekdaySelector({
//     super.key,
//     required this.selectedDay,
//     required this.onDaySelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final days = WeekDay.values;

//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return SizedBox(
//       height: 44,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: days.length,
//         separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
//         itemBuilder: (context, index) {
//           final day = days[index];
//           final isSelected = day == selectedDay;

//           return Material(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//               onTap: () => onDaySelected(day),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeOut,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppSizes.lg,
//                   vertical: AppSizes.sm,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isSelected ? colorScheme.primary : colorScheme.surface,
//                   borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//                   border: Border.all(
//                     color: isSelected
//                         ? colorScheme.primary
//                         : colorScheme.outline.withValues(alpha: .65),
//                   ),
//                   boxShadow: isSelected
//                       ? [
//                           BoxShadow(
//                             color: colorScheme.primary.withValues(alpha: .16),
//                             blurRadius: 8,
//                             offset: const Offset(0, 3),
//                           ),
//                         ]
//                       : null,
//                 ),
//                 alignment: Alignment.center,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (isSelected) ...[
//                       const Icon(
//                         Icons.check_rounded,
//                         size: AppSizes.iconSm,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: AppSizes.xs),
//                     ],
//                     Text(
//                       day.shortName,
//                       style: AppTextStyles.labelLarge.copyWith(
//                         color: isSelected
//                             ? Colors.white
//                             : colorScheme.onSurface,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
