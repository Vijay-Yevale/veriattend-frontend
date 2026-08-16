// // lib/features/attendance/presentation/widgets/attendance_review_view.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:veriattend_app/core/constants/app_colors.dart';
// import 'package:veriattend_app/core/constants/app_sizes.dart';
// import 'package:veriattend_app/core/constants/app_text_styles.dart';
// import 'package:veriattend_app/core/utils/snackbar.dart';

// import 'package:veriattend_app/core/widgets/app_button.dart';
// import 'package:veriattend_app/core/widgets/app_search_bar.dart';
// import 'package:veriattend_app/core/widgets/confirmation_dialog.dart';
// import 'package:veriattend_app/core/widgets/reason_dialog.dart';
// import 'package:veriattend_app/core/widgets/section_card.dart';
// import 'package:veriattend_app/core/widgets/stat_tile.dart';

// import 'package:veriattend_app/features/attendance/domain/model/attendance_session_roster_model.dart';
// import 'package:veriattend_app/features/attendance/presentation/providers/attendance_action_provider.dart';
// import 'package:veriattend_app/features/attendance/presentation/widgets/attendance_student_tile.dart';

// class AttendanceReviewView extends ConsumerStatefulWidget {
//   const AttendanceReviewView({super.key});

//   @override
//   ConsumerState<AttendanceReviewView> createState() =>
//       _AttendanceReviewViewState();
// }

// class _AttendanceReviewViewState extends ConsumerState<AttendanceReviewView> {
//   final TextEditingController _searchController = TextEditingController();

//   String _query = '';

//   final Set<String> _selectedStudents = <String>{};

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ==========================================================
//   // MANUAL ATTENDANCE
//   // ==========================================================

//   Future<void> _showReasonDialog() async {
//     // Take a snapshot before opening dialogs.
//     final selectedStudents = _selectedStudents.toList();

//     if (selectedStudents.isEmpty) return;

//     final reason = await ReasonDialog.show(
//       context,
//       title: 'Manual Attendance',
//       hintText: 'Enter reason for manual attendance',
//       confirmText: 'Mark Present',
//     );

//     if (!mounted || reason == null) return;

//     final confirmed = await ConfirmationDialog.show(
//       context,
//       title: 'Confirm Attendance',
//       message:
//           'Mark ${selectedStudents.length} selected student(s) '
//           'as Present?\n\n'
//           'Reason:\n$reason',
//       confirmText: 'Confirm',
//     );

//     if (!mounted || !confirmed) return;

//     try {
//       await ref
//           .read(attendanceActionProvider.notifier)
//           .markManualAttendance(studentIds: selectedStudents, reason: reason);

//       if (!mounted) return;

//       setState(() {
//         _selectedStudents.clear();
//       });

//       showSuccessSnackBar(context, 'Attendance updated successfully.');
//     } catch (e) {
//       if (!mounted) return;

//       final message = e is Exception
//           ? e.toString().replaceFirst('Exception: ', '')
//           : 'Something went wrong.';

//       showErrorSnackBar(context, message);
//     }
//   }

//   // ==========================================================
//   // BUILD
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     final attendanceState = ref.watch(attendanceActionProvider);

//     // This view is only visible when a review exists.
//     if (attendanceState is! AttendanceReview) {
//       return const SizedBox.shrink();
//     }

//     final roster = attendanceState.roster;

//     final presentStudents = roster.presentList.where(_matchesSearch).toList();

//     final absentStudents = roster.absentList.where(_matchesSearch).toList();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // ------------------------------------------------------
//         // SUMMARY
//         // ------------------------------------------------------
//         _buildSummaryCard(roster),

//         const SizedBox(height: AppSizes.lg),

//         // ------------------------------------------------------
//         // SEARCH
//         // ------------------------------------------------------
//         AppSearchBar(
//           controller: _searchController,
//           hintText: 'Search student',
//           onChanged: (value) {
//             setState(() {
//               _query = value.trim().toLowerCase();
//             });
//           },
//         ),

//         const SizedBox(height: AppSizes.lg),

//         // ------------------------------------------------------
//         // PRESENT STUDENTS
//         // ------------------------------------------------------
//         _buildPresentSection(presentStudents),

//         const SizedBox(height: AppSizes.lg),

//         // ------------------------------------------------------
//         // ABSENT STUDENTS
//         // ------------------------------------------------------
//         _buildAbsentSection(absentStudents),

//         // ------------------------------------------------------
//         // MANUAL ATTENDANCE ACTION
//         // ------------------------------------------------------
//         if (_selectedStudents.isNotEmpty) ...[
//           const SizedBox(height: AppSizes.lg),

//           _buildManualAttendanceSection(),
//         ],

//         const SizedBox(height: AppSizes.lg),

//         // ------------------------------------------------------
//         // DONE
//         // ------------------------------------------------------
//         AppButton(
//           label: 'Done',
//           icon: Icons.check_circle_outline,
//           onPressed: () {
//             ref.read(attendanceActionProvider.notifier).resetAttendance();
//           },
//         ),

//         const SizedBox(height: AppSizes.lg),
//       ],
//     );
//   }

//   // ==========================================================
//   // SEARCH
//   // ==========================================================

//   bool _matchesSearch(dynamic student) {
//     if (_query.isEmpty) {
//       return true;
//     }

//     final userName = student.userName.toString().toLowerCase();

//     final prn = (student.prn ?? '').toString().toLowerCase();

//     return userName.contains(_query) || prn.contains(_query);
//   }

//   // ==========================================================
//   // SUMMARY CARD
//   // ==========================================================

//   Widget _buildSummaryCard(SessionRosterModel roster) {
//     return SectionCard(
//       title: 'Attendance Summary',
//       showArrow: false,
//       child: StatTileRow(
//         tiles: [
//           StatTile(
//             icon: Icons.check_circle,
//             label: 'Present',
//             value: '${roster.presentCount}',
//             color: AppColors.success,
//           ),
//           StatTile(
//             icon: Icons.cancel,
//             label: 'Absent',
//             value: '${roster.absentCount}',
//             color: AppColors.error,
//           ),
//           StatTile(
//             icon: Icons.groups,
//             label: 'Total',
//             value: '${roster.totalStudents}',
//             color: AppColors.primary,
//           ),
//         ],
//       ),
//     );
//   }

//   // ==========================================================
//   // PRESENT STUDENTS
//   // ==========================================================

//   Widget _buildPresentSection(List students) {
//     return SectionCard(
//       title: 'Present Students (${students.length})',
//       showArrow: false,
//       child: students.isEmpty
//           ? _buildEmptyState(
//               _query.isEmpty
//                   ? 'No present students.'
//                   : 'No matching present students.',
//             )
//           : Column(
//               children: students
//                   .map(
//                     (student) => AttendanceStudentTile(
//                       student: student,
//                       trailing: const Icon(
//                         Icons.check_circle,
//                         color: AppColors.success,
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//     );
//   }

//   // ==========================================================
//   // ABSENT STUDENTS
//   // ==========================================================

//   Widget _buildAbsentSection(List students) {
//     return SectionCard(
//       title: 'Absent Students (${students.length})',
//       showArrow: false,
//       child: students.isEmpty
//           ? _buildEmptyState(
//               _query.isEmpty
//                   ? 'No absent students.'
//                   : 'No matching absent students.',
//             )
//           : Column(
//               children: students
//                   .map(
//                     (student) => AttendanceStudentTile(
//                       student: student,
//                       showCheckbox: true,
//                       isSelected: _selectedStudents.contains(student.studentId),
//                       onChanged: (value) {
//                         setState(() {
//                           if (value ?? false) {
//                             _selectedStudents.add(student.studentId);
//                           } else {
//                             _selectedStudents.remove(student.studentId);
//                           }
//                         });
//                       },
//                     ),
//                   )
//                   .toList(),
//             ),
//     );
//   }

//   // ==========================================================
//   // MANUAL ATTENDANCE SECTION
//   // ==========================================================

//   Widget _buildManualAttendanceSection() {
//     return SectionCard(
//       title: 'Manual Attendance',
//       showArrow: false,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             '${_selectedStudents.length} student(s) selected',
//             style: AppTextStyles.bodyMedium.copyWith(
//               color: AppColors.lightTextSecondary,
//             ),
//           ),

//           const SizedBox(height: AppSizes.md),

//           AppButton(
//             label: 'Mark Selected Present',
//             icon: Icons.how_to_reg_rounded,
//             onPressed: _showReasonDialog,
//           ),
//         ],
//       ),
//     );
//   }

//   // ==========================================================
//   // EMPTY STATE
//   // ==========================================================

//   Widget _buildEmptyState(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
//       child: Center(
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: AppColors.lightTextSecondary,
//           ),
//         ),
//       ),
//     );
//   }
// }
