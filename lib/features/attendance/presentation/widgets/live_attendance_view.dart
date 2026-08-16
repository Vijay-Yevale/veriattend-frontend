import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/widgets/app_button.dart';
import 'package:veriattend_app/core/widgets/section_card.dart';
import 'package:veriattend_app/core/widgets/stat_tile.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/features/attendance/presentation/providers/attendance_action_provider.dart';

class AttendanceLiveView extends ConsumerStatefulWidget {
  final AttendanceLive state;

  const AttendanceLiveView({super.key, required this.state});

  @override
  ConsumerState<AttendanceLiveView> createState() => _AttendanceLiveViewState();
}

class _AttendanceLiveViewState extends ConsumerState<AttendanceLiveView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _refreshIn {
    final seconds =
        (widget.state.session.qrExpiry
                    .difference(DateTime.now())
                    .inMilliseconds /
                1000)
            .ceil();

    return "${seconds.clamp(0, 999)}s";
  }

  String get _endsIn {
    final diff = widget.state.session.expiresAt.difference(DateTime.now());

    if (diff.inMilliseconds <= 0) {
      return "00:00";
    }

    final totalSeconds = (diff.inMilliseconds / 1000).ceil();

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _openFullScreenQr() {
    context.push(AppRoutes.attendanceFullScreenQrRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildQrCard(),

        const SizedBox(height: AppSizes.lg),

        _buildStatsCard(),

        const SizedBox(height: AppSizes.lg),

        AppButton(
          label: "End Attendance",
          icon: Icons.stop_circle_outlined,
          onPressed: () {
            ref.read(attendanceActionProvider.notifier).endAttendance();
          },
        ),
      ],
    );
  }

  Widget _buildQrCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SectionCard(
      title: "Attendance QR",
      showArrow: false,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 340,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.55),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: widget.state.session.qrToken,
                    version: QrVersions.auto,
                    size: 260,
                  ),
                ),
              ),

              // Full screen
              Positioned(
                top: AppSizes.md,
                right: AppSizes.md,
                child: Material(
                  color: colorScheme.surface,
                  elevation: 1,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    onTap: _openFullScreenQr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm + 2,
                        vertical: AppSizes.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fullscreen_rounded,
                            size: AppSizes.iconSm + 2,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            "Full Screen",
                            style: AppTextStyles.labelMedium.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Live badge
              Positioned(
                top: AppSizes.md,
                left: AppSizes.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "LIVE",
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                size: AppSizes.iconSm,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSizes.xs),
              Flexible(
                child: Text(
                  "Scan the latest QR to mark attendance.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return SectionCard(
      title: "Attendance Status",
      showArrow: false,
      child: StatTileRow(
        tiles: [
          StatTile(
            icon: Icons.groups_rounded,
            label: "Present",
            value: "${widget.state.presentCount}",
            color: AppColors.primary,
          ),
          StatTile(
            icon: Icons.qr_code_2_rounded,
            label: "Version",
            value: "${widget.state.session.qrVersion}",
            color: AppColors.warning,
          ),
          StatTile(
            icon: Icons.refresh_rounded,
            label: "Refresh",
            value: _refreshIn,
            color: AppColors.info,
          ),
          StatTile(
            icon: Icons.timer_outlined,
            label: "Ends In",
            value: _endsIn,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}
