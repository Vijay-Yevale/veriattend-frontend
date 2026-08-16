import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/utils/snackbar.dart';
import 'package:veriattend_app/features/attendance/presentation/providers/attendance_active_session_provider.dart';
import 'package:veriattend_app/features/attendance/presentation/providers/student_submit_attendance_provider.dart';

class StudentQrScannerScreen extends ConsumerStatefulWidget {
  const StudentQrScannerScreen({super.key});

  @override
  ConsumerState<StudentQrScannerScreen> createState() =>
      _StudentQrScannerScreenState();
}

class _StudentQrScannerScreenState
    extends ConsumerState<StudentQrScannerScreen> {
  late final MobileScannerController _controller;

  bool _flashOn = false;
  bool _isProcessing = false;
  String? _lastQrToken;

  late final ProviderSubscription<StudentSubmitAttendanceState>
  _submitSubscription;

  @override
  void initState() {
    super.initState();

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _submitSubscription = ref.listenManual<StudentSubmitAttendanceState>(
      studentSubmitAttendanceProvider,
      (previous, next) async {
        if (!mounted) return;

        if (next is StudentSubmitSuccess) {
          final verificationToken = next.verificationToken;

          ref.read(studentSubmitAttendanceProvider.notifier).reset();

          if (!mounted) return;

          await context.push(
            AppRoutes.studentFaceVerifyRoute,
            extra: verificationToken,
          );

          if (!mounted) return;

          _isProcessing = false;
          _lastQrToken = null;

          await _controller.start();

          return;
        }

        if (next is StudentSubmitError) {
          ref.read(studentSubmitAttendanceProvider.notifier).reset();

          showErrorSnackBar(context, next.message);

          if (next.shouldCloseScanner) {
            ref.invalidate(studentActiveSessionProvider);

            context.pop();
          } else {
            _isProcessing = false;
            _lastQrToken = null;

            await _controller.start();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _submitSubscription.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;

    if (barcode == null) return;

    final qrToken = barcode.rawValue;

    if (qrToken == null || qrToken.isEmpty) return;

    if (_lastQrToken == qrToken) return;

    _lastQrToken = qrToken;
    _isProcessing = true;

    await _controller.stop();

    if (!mounted) return;

    await ref
        .read(studentSubmitAttendanceProvider.notifier)
        .submitAttendance(qrToken: qrToken);
  }

  Future<void> _toggleFlash() async {
    await _controller.toggleTorch();

    if (!mounted) return;

    setState(() {
      _flashOn = !_flashOn;
    });
  }

  Future<void> _closeScanner() async {
    await _controller.stop();

    if (!mounted) return;

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(studentSubmitAttendanceProvider);

    final isLoading = submitState is StudentSubmitLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          Container(color: Colors.black.withValues(alpha: 0.22)),

          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(color: AppColors.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _Corner(alignment: Alignment.topLeft),
                  _Corner(alignment: Alignment.topRight),
                  _Corner(alignment: Alignment.bottomLeft),
                  _Corner(alignment: Alignment.bottomRight),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  _ScannerButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: _closeScanner,
                  ),

                  const Spacer(),

                  _ScannerButton(
                    icon: _flashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    tooltip: _flashOn ? 'Turn flash off' : 'Turn flash on',
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 28,
                      ),

                      const SizedBox(height: AppSizes.sm),

                      Text(
                        "Scan Attendance QR",
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: AppSizes.xs),

                      Text(
                        "Align the QR code inside the frame.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.58),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: AppSizes.md),
                      Text(
                        'Verifying QR...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ScannerButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: AppSizes.iconMd),
        onPressed: onPressed,
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;

  const _Corner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: AppColors.primary, width: 5)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: AppColors.primary, width: 5)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: AppColors.primary, width: 5)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: AppColors.primary, width: 5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
