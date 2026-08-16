import 'package:flutter/material.dart';

import 'package:veriattend_app/core/widgets/empty_dashboard_widget.dart';

class StudentNoActiveSessionView extends StatelessWidget {
  const StudentNoActiveSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: EmptyDashboardWidget(
        icon: Icons.qr_code_scanner_outlined,
        title: "No Active Attendance",
        message:
            "There is no attendance session running for your class at the moment.\n\nPull down to refresh.",
      ),
    );
  }
}
