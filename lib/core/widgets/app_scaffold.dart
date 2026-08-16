// lib/core/widgets/app_scaffold.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:veriattend_app/core/router/app_router.dart';

import '../constants/app_text_styles.dart';

class AppNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class AppScaffold extends StatelessWidget {
  final Widget body;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final List<AppNavItem> navItems;
  final String currentRoute;
  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    required this.navItems,
    required this.currentRoute,
    this.showAppBar = true,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  int _currentIndex() {
    return navItems.indexWhere((e) => e.route == currentRoute);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex();

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              centerTitle: false,
              title: Text(title ?? '', style: AppTextStyles.appBarTitle),
              actions: actions,
            )
          : null,
      body: SafeArea(top: !showAppBar, child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) return;

          context.go(navItems[index].route);
        },
        destinations: navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class StudentNavItems {
  static const items = <AppNavItem>[
    AppNavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      route: AppRoutes.student,
    ),
    AppNavItem(
      label: 'Timetable',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      route: AppRoutes.myTimetableRoute,
    ),
    AppNavItem(
      label: 'Scan',
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner,
      route: AppRoutes.studentScanQrRoute,
    ),
    AppNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person,
      route: AppRoutes.studentProfile,
    ),
  ];
}

class AdminNavItems {
  static const items = <AppNavItem>[
    AppNavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.admin,
    ),
    AppNavItem(
      label: 'Manage',
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts,
      route: AppRoutes.adminManage,
    ),
    AppNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: AppRoutes.adminProfile,
    ),
  ];
}

class HodNavItems {
  static const items = <AppNavItem>[
    AppNavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.hod,
    ),
    AppNavItem(
      label: 'Manage',
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts,
      route: AppRoutes.hodmanage,
    ),
    AppNavItem(
      label: 'Timetable',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      route: AppRoutes.hodTimetable,
    ),
    AppNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: AppRoutes.hodProfile,
    ),
  ];
}

class TeacherNavItems {
  static const items = <AppNavItem>[
    AppNavItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      route: AppRoutes.teacher,
    ),
    AppNavItem(
      label: 'History',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
      route: AppRoutes.teacherSessionHistoryRoute,
    ),
    AppNavItem(
      label: 'Manage',
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts,
      route: AppRoutes.teacherManage,
    ),
    AppNavItem(
      label: 'Timetable',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      route: AppRoutes.myTimetableRoute,
    ),
    AppNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person,
      route: AppRoutes.teacherProfile,
    ),
  ];
}
