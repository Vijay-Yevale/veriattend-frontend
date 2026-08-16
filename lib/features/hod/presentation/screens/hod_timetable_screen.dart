import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/model/class_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';
import 'package:veriattend_app/core/widgets/app_scaffold.dart';
import 'package:veriattend_app/core/widgets/app_search_bar.dart';
import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';
import 'package:veriattend_app/core/widgets/greeting_section.dart';
import 'package:veriattend_app/core/widgets/quick_action_card.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:veriattend_app/features/hod/presentation/providers/manage_provider.dart';

class HodTimetableScreen extends ConsumerStatefulWidget {
  const HodTimetableScreen({super.key});

  @override
  ConsumerState<HodTimetableScreen> createState() => _HodTimetableScreenState();
}

class _HodTimetableScreenState extends ConsumerState<HodTimetableScreen> {
  static const int _initialVisibleItems = 3;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  bool _showAllClasses = false;
  bool _showAllTeachers = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(classesProvider);
    ref.invalidate(teachersProvider);

    await Future.wait([
      ref.read(classesProvider.future),
      ref.read(teachersProvider.future),
    ]);
  }

  List<ClassModel> _filterClasses(List<ClassModel> classes) {
    if (_searchQuery.isEmpty) return classes;

    final query = _searchQuery.toLowerCase();

    return classes.where((classModel) {
      final className = classModel.className.toLowerCase();

      final teacherName = classModel.classTeacher?.userName.toLowerCase() ?? '';

      return className.contains(query) || teacherName.contains(query);
    }).toList();
  }

  List<UserModel> _filterTeachers(List<UserModel> teachers) {
    if (_searchQuery.isEmpty) return teachers;

    final query = _searchQuery.toLowerCase();

    return teachers.where((teacher) {
      return teacher.userName.toLowerCase().contains(query) ||
          teacher.email.toLowerCase().contains(query);
    }).toList();
  }

  List<ClassModel> _visibleClasses(List<ClassModel> classes) {
    if (_showAllClasses || classes.length <= _initialVisibleItems) {
      return classes;
    }

    return classes.take(_initialVisibleItems).toList();
  }

  List<UserModel> _visibleTeachers(List<UserModel> teachers) {
    if (_showAllTeachers || teachers.length <= _initialVisibleItems) {
      return teachers;
    }

    return teachers.take(_initialVisibleItems).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final userName = authState is AuthAuthenticated
        ? authState.user.userName
        : 'User';

    final classesAsync = ref.watch(classesProvider);
    final teachersAsync = ref.watch(teachersProvider);

    if (classesAsync.isLoading || teachersAsync.isLoading) {
      return const AppScaffold(
        body: Center(child: AppLoader()),
        navItems: HodNavItems.items,
        currentRoute: AppRoutes.hodTimetable,
        title: 'Timetable',
      );
    }

    if (classesAsync.hasError) {
      return AppScaffold(
        body: AppErrorWidget(
          message: classesAsync.error.toString(),
          onRetry: () => ref.invalidate(classesProvider),
        ),
        navItems: HodNavItems.items,
        currentRoute: AppRoutes.hodTimetable,
        title: 'Timetable',
      );
    }

    if (teachersAsync.hasError) {
      return AppScaffold(
        body: AppErrorWidget(
          message: teachersAsync.error.toString(),
          onRetry: () => ref.invalidate(teachersProvider),
        ),
        navItems: HodNavItems.items,
        currentRoute: AppRoutes.hodTimetable,
        title: 'Timetable',
      );
    }

    final classes = _filterClasses(classesAsync.requireValue);

    final teachers = _filterTeachers(teachersAsync.requireValue);

    final visibleClasses = _visibleClasses(classes);

    final visibleTeachers = _visibleTeachers(teachers);

    final noResults = classes.isEmpty && teachers.isEmpty;

    return AppScaffold(
      navItems: HodNavItems.items,
      currentRoute: AppRoutes.hodTimetable,
      title: 'Timetable',
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPaddingH,
                AppSizes.screenPaddingV,
                AppSizes.screenPaddingH,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingSection(
                    userName: userName,
                    subtitle: 'Manage classes and faculty for your department.',
                  ),

                  const SizedBox(height: AppSizes.lg),

                  AppSearchBar(
                    controller: _searchController,
                    hintText: 'Search classes or teachers',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.sm),

            Expanded(
              child: noResults
                  ? _EmptyState(
                      title: _searchQuery.isEmpty
                          ? 'No Timetable Data'
                          : 'No Results Found',
                      message: _searchQuery.isEmpty
                          ? 'No classes or teachers are available.'
                          : 'Try a different search term.',
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.screenPaddingH,
                        AppSizes.xl,
                        AppSizes.screenPaddingH,
                        AppSizes.screenPaddingV,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (classes.isNotEmpty)
                            SectionCard(
                              title: 'Classes',
                              trailing: classes.length > _initialVisibleItems
                                  ? TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showAllClasses = !_showAllClasses;
                                        });
                                      },
                                      child: Text(
                                        _showAllClasses
                                            ? 'Show Less'
                                            : 'View All',
                                      ),
                                    )
                                  : null,
                              child: Column(
                                children: [
                                  for (
                                    int index = 0;
                                    index < visibleClasses.length;
                                    index++
                                  ) ...[
                                    QuickActionCard(
                                      icon: Icons.school_rounded,
                                      title: visibleClasses[index].className,
                                      subtitle:
                                          'Class Teacher: ${visibleClasses[index].classTeacher?.userName ?? "Not Assigned"}',
                                      onTap: () {
                                        context.push(
                                          AppRoutes.classTimetable(
                                            visibleClasses[index].id,
                                          ),
                                        );
                                      },
                                    ),

                                    if (index != visibleClasses.length - 1)
                                      const SizedBox(height: AppSizes.md),
                                  ],
                                ],
                              ),
                            ),

                          if (classes.isNotEmpty && teachers.isNotEmpty)
                            const SizedBox(height: AppSizes.xl),

                          if (teachers.isNotEmpty)
                            SectionCard(
                              title: 'Teachers',
                              trailing: teachers.length > _initialVisibleItems
                                  ? TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _showAllTeachers = !_showAllTeachers;
                                        });
                                      },
                                      child: Text(
                                        _showAllTeachers
                                            ? 'Show Less'
                                            : 'View All',
                                      ),
                                    )
                                  : null,
                              child: Column(
                                children: [
                                  for (
                                    int index = 0;
                                    index < visibleTeachers.length;
                                    index++
                                  ) ...[
                                    QuickActionCard(
                                      icon: Icons.person_rounded,
                                      title: visibleTeachers[index].userName,
                                      subtitle: visibleTeachers[index].email,
                                      onTap: () {
                                        context.push(
                                          AppRoutes.teacherTimetableFor(
                                            visibleTeachers[index].id,
                                          ),
                                          extra:
                                              visibleTeachers[index].userName,
                                        );
                                      },
                                    ),

                                    if (index != visibleTeachers.length - 1)
                                      const SizedBox(height: AppSizes.md),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
            vertical: AppSizes.xl,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - (2 * AppSizes.xl)).clamp(
                0,
                double.infinity,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [EmptyDashboardWidget(title: title, message: message)],
            ),
          ),
        );
      },
    );
  }
}
