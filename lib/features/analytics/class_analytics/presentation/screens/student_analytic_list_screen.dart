import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';

import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_filter_model.dart';
import 'package:veriattend_app/features/analytics/class_analytics/domain/model/dashboard_student_model.dart';

import 'package:veriattend_app/features/analytics/class_analytics/presentation/providers/class_analytics_provider.dart';
import 'package:veriattend_app/features/analytics/class_analytics/presentation/providers/subject_dashboard_provider.dart';

import '../widgets/dashboard_filter_chips.dart';
import '../../../../../core/widgets/app_search_bar.dart';
import '../widgets/dashboard_student_tile.dart';

class StudentAnalyticsListScreen extends ConsumerStatefulWidget {
  final String classId;

  final String? subjectId;

  final String? subjectName;

  const StudentAnalyticsListScreen({
    super.key,
    required this.classId,
    this.subjectId,
    this.subjectName,
  });

  bool get isSubjectMode => subjectId != null;

  @override
  ConsumerState<StudentAnalyticsListScreen> createState() =>
      _StudentAnalyticsListScreenState();
}

class _StudentListData {
  final List<DashboardStudentModel> students;
  final DashboardFiltersModel filters;

  const _StudentListData({required this.students, required this.filters});
}

class _StudentAnalyticsListScreenState
    extends ConsumerState<StudentAnalyticsListScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  DashboardFilterType _selectedFilter = DashboardFilterType.all;

  SubjectDashboardParams get _subjectParams => SubjectDashboardParams(
    classId: widget.classId,
    subjectId: widget.subjectId!,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _invalidateDashboard();
    }
  }

  void _invalidateDashboard() {
    if (widget.isSubjectMode) {
      ref.invalidate(subjectDashboardProvider(_subjectParams));
    } else {
      ref.invalidate(classDashboardProvider(widget.classId));
    }
  }

  Future<void> _refresh() async {
    _invalidateDashboard();

    if (widget.isSubjectMode) {
      await ref.read(subjectDashboardProvider(_subjectParams).future);
    } else {
      await ref.read(classDashboardProvider(widget.classId).future);
    }
  }

  void _goToStudentDetail(DashboardStudentModel student) {
    if (!widget.isSubjectMode) {
      context.push(AppRoutes.studentDashboard(student.studentId));
    } else {
      context.push(
        AppRoutes.studentSubjectDetail(student.studentId, widget.subjectId!),
        extra: widget.subjectName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<_StudentListData> dashboard = widget.isSubjectMode
        ? ref
              .watch(subjectDashboardProvider(_subjectParams))
              .whenData(
                (data) => _StudentListData(
                  students: data.students,
                  filters: data.filters ?? const DashboardFiltersModel.empty(),
                ),
              )
        : ref
              .watch(classDashboardProvider(widget.classId))
              .whenData(
                (data) => _StudentListData(
                  students: data.students,
                  filters: data.filters ?? const DashboardFiltersModel.empty(),
                ),
              );

    final body = dashboard.when(
      loading: () => const AppLoader(),

      error: (error, _) {
        return AppErrorWidget(
          message: error.toString(),
          onRetry: _invalidateDashboard,
        );
      },

      data: (data) {
        if (data.students.isEmpty) {
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
                      title: "No students found",
                      message:
                          "Students will appear here once they are assigned to this class.",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        List<DashboardStudentModel> students = List.from(data.students);

        final query = _searchController.text.trim().toLowerCase();

        if (query.isNotEmpty) {
          students = students.where((student) {
            return student.userName.toLowerCase().contains(query) ||
                student.prn.toLowerCase().contains(query);
          }).toList();
        }

        switch (_selectedFilter) {
          case DashboardFilterType.highRisk:
            students = students
                .where((s) => data.filters.highRisk.contains(s.studentId))
                .toList();
            break;

          case DashboardFilterType.mediumRisk:
            students = students
                .where((s) => data.filters.mediumRisk.contains(s.studentId))
                .toList();
            break;

          case DashboardFilterType.lowRisk:
            students = students
                .where((s) => data.filters.lowRisk.contains(s.studentId))
                .toList();
            break;

          case DashboardFilterType.defaulters:
            students = students
                .where((s) => data.filters.defaulters.contains(s.studentId))
                .toList();
            break;

          case DashboardFilterType.all:
            break;
        }

        students.sort((a, b) => a.userName.compareTo(b.userName));

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.screenPaddingH),
            children: [
              AppSearchBar(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                onClear: () => setState(() {}),
                hintText: 'Search by name or PRN',
              ),

              const SizedBox(height: AppSizes.lg),

              DashboardFilterChips(
                selectedFilter: _selectedFilter,
                onSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                highRiskCount: data.filters.highRisk.length,
                mediumRiskCount: data.filters.mediumRisk.length,
                lowRiskCount: data.filters.lowRisk.length,
                defaultersCount: data.filters.defaulters.length,
              ),

              const SizedBox(height: AppSizes.lg),

              if (students.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSizes.xxl),
                  child: EmptyDashboardWidget(
                    title: "No matching students",
                    message: "No students match the current search or filter.",
                  ),
                )
              else
                ...students.map(
                  (student) => DashboardStudentTile(
                    student: student,
                    onTap: () => _goToStudentDetail(student),
                  ),
                ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSubjectMode
              ? "${widget.subjectName} Students"
              : "Student Analytics",
        ),
        centerTitle: false,
      ),
      body: body,
    );
  }
}
