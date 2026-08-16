import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:veriattend_app/features/attendance/presentation/providers/attendance_action_provider.dart';

class AttendanceFullScreenQrView extends ConsumerStatefulWidget {
  const AttendanceFullScreenQrView({super.key});

  @override
  ConsumerState<AttendanceFullScreenQrView> createState() =>
      _AttendanceFullScreenQrViewState();
}

class _AttendanceFullScreenQrViewState
    extends ConsumerState<AttendanceFullScreenQrView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void dispose() {
    _timer.cancel();

    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    super.dispose();
  }

  String _refreshIn(AttendanceLive state) {
    final seconds =
        (state.session.qrExpiry.difference(DateTime.now()).inMilliseconds /
                1000)
            .ceil();

    return "${seconds.clamp(0, 999)}s";
  }

  String _endsIn(AttendanceLive state) {
    final diff = state.session.expiresAt.difference(DateTime.now());

    if (diff.inMilliseconds <= 0) {
      return "00:00";
    }

    final totalSeconds = (diff.inMilliseconds / 1000).ceil();

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceActionProvider);

    if (attendanceState is! AttendanceLive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) {
          context.pop();
        }
      });
    }

    final liveState = attendanceState is AttendanceLive
        ? attendanceState
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: liveState == null
            ? const SizedBox.shrink()
            : LayoutBuilder(
                builder: (context, constraints) {
                  final widthBound = constraints.maxWidth * 0.65;
                  final heightBound = constraints.maxHeight * 0.55;

                  final qrSize =
                      (widthBound < heightBound ? widthBound : heightBound)
                          .clamp(180.0, 600.0);

                  return Stack(
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // QR
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: liveState.session.qrToken,
                                  version: QrVersions.auto,
                                  size: qrSize,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Present count
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.people_alt_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Present: ${liveState.presentCount}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Countdown information
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _CountdownItem(
                                    icon: Icons.refresh_rounded,
                                    label: "Refresh",
                                    value: _refreshIn(liveState),
                                  ),
                                  const SizedBox(width: 12),
                                  _CountdownItem(
                                    icon: Icons.timer_outlined,
                                    label: "Ends In",
                                    value: _endsIn(liveState),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Close
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.10),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: "Close",
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ),

                      // Live indicator
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LiveDot(),
                              SizedBox(width: 7),
                              Text(
                                "LIVE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _CountdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CountdownItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.80), size: 17),
          const SizedBox(width: 7),
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
  }
}
