import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';

import 'package:veriattend_app/core/widgets/alert_banner.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/providers/student_subject_detail_provider.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/widgets/subject_risk_card.dart';

import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/academic_card.dart';
import 'package:veriattend_app/features/analytics/studentanalytics/presentation/widgets/attendance_card.dart';

class StudentSubjectDetailScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String subjectId;
  final String? subjectName;

  const StudentSubjectDetailScreen({
    super.key,
    required this.studentId,
    required this.subjectId,
    this.subjectName,
  });

  @override
  ConsumerState<StudentSubjectDetailScreen> createState() =>
      _StudentSubjectDetailScreenState();
}

class _StudentSubjectDetailScreenState
    extends ConsumerState<StudentSubjectDetailScreen>
    with WidgetsBindingObserver {
  StudentSubjectDetailParams get _params => StudentSubjectDetailParams(
    studentId: widget.studentId,
    subjectId: widget.subjectId,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(studentSubjectDetailProvider(_params));
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(studentSubjectDetailProvider(_params));

    await ref.read(studentSubjectDetailProvider(_params).future);
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(studentSubjectDetailProvider(_params));

    final body = analytics.when(
      loading: () => const AppLoader(),

      error: (error, _) {
        return AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(studentSubjectDetailProvider(_params));
          },
        );
      },

      data: (data) {
        final subject = data.subject;

        final attendance = subject.attendance;
        final academic = subject.academicMarks;
        final risk = subject.risk;

        final hasAttendance = attendance.hasData;
        final hasAcademic = academic.hasData;

        final noData = !hasAttendance && !hasAcademic;

        if (noData) {
          final availableHeight =
              MediaQuery.of(context).size.height - kToolbarHeight;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenPaddingH,
              ),
              children: [
                SizedBox(
                  height: availableHeight,
                  child: const Align(
                    alignment: Alignment(0, -.35),
                    child: EmptyDashboardWidget(
                      title: "No subject analytics available",
                      message:
                          "Analytics will appear once attendance and marks are available for this subject.",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPaddingH),
            children: [
              // Subject information
              SectionCard(
                title: subject.subjectName,
                showArrow: false,
                child: Text(
                  subject.subjectCode,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Attendance
              if (hasAttendance) ...[
                if (attendance.classesNeededFor75 > 0) ...[
                  AlertBanner(
                    type: BannerType.warning,
                    message:
                        "Attend ${attendance.classesNeededFor75} more classes in this subject to reach 75% attendance.",
                  ),

                  const SizedBox(height: AppSizes.md),
                ],

                AttendanceCard(attendance: attendance),
              ] else
                const AlertBanner(
                  type: BannerType.info,
                  message:
                      "Attendance has not been recorded for this subject yet.",
                ),

              const SizedBox(height: AppSizes.lg),

              // Academic
              if (hasAcademic)
                AcademicCard(academic: academic)
              else
                const AlertBanner(
                  type: BannerType.info,
                  message:
                      "Academic marks have not been entered for this subject yet.",
                ),

              const SizedBox(height: AppSizes.lg),

              // Risk
              if (risk.riskLevel == "HIGH") ...[
                const AlertBanner(
                  type: BannerType.error,
                  message:
                      "This student is currently at HIGH risk in this subject.",
                ),

                const SizedBox(height: AppSizes.md),
              ],
              SubjectRiskCard(risk: risk),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.subjectName ?? "Subject Analytics"),
        centerTitle: false,
      ),
      body: body,
    );
  }
}
