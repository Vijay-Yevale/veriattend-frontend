import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/router/app_router.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/snackbar.dart';
import 'package:veriattend_app/features/attendance/presentation/providers/face_verify_attendance_provider.dart';
import 'package:veriattend_app/features/face/presentation/widgets/face_camera_view.dart';

class FaceVerificationScreen extends ConsumerStatefulWidget {
  final String verificationToken;

  const FaceVerificationScreen({super.key, required this.verificationToken});

  @override
  ConsumerState<FaceVerificationScreen> createState() =>
      _FaceVerificationScreenState();
}

class _FaceVerificationScreenState
    extends ConsumerState<FaceVerificationScreen> {
  late final ProviderSubscription<ActionState> _verificationSubscription;

  bool _showSuccess = false;
  bool _hasSubmitted = false;
  int _cameraAttempt = 0;

  @override
  void initState() {
    super.initState();

    _verificationSubscription = ref.listenManual<ActionState>(
      faceVerifyAttendanceProvider,
      (previous, next) {
        if (!mounted) return;

        if (next is ActionSuccess) {
          setState(() {
            _showSuccess = true;
            _hasSubmitted = false;
          });

          return;
        }

        if (next is ActionError) {
          showErrorSnackBar(context, next.message);

          ref.read(faceVerifyAttendanceProvider.notifier).reset();

          setState(() {
            _hasSubmitted = false;
            _cameraAttempt++;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _verificationSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(faceVerifyAttendanceProvider);

    final isSubmitting = verificationState is ActionLoading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Face Verification')),
      body: SafeArea(
        child: _showSuccess
            ? _buildSuccessView()
            : Column(
                children: [
                  const SizedBox(height: AppSizes.md),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.face_retouching_natural_rounded,
                            color: colorScheme.primary,
                            size: AppSizes.iconLg,
                          ),
                        ),

                        const SizedBox(height: AppSizes.sm),

                        Text(
                          'Verify Your Face',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSizes.xs),

                        Text(
                          'Position your face inside the frame and hold still.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),

                  Expanded(
                    child: FaceCameraView(
                      key: ValueKey(_cameraAttempt),
                      isSubmitting: isSubmitting,
                      onCaptured: (embedding) {
                        if (_hasSubmitted || isSubmitting) {
                          return;
                        }

                        setState(() {
                          _hasSubmitted = true;
                        });

                        ref
                            .read(faceVerifyAttendanceProvider.notifier)
                            .verifyFaceAndMarkAttendance(
                              verificationToken: widget.verificationToken,
                              embedding: embedding,
                            );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSuccessView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.20),
                  width: 1.5,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            Text(
              'Attendance Marked',
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.sm),

            Text(
              'Your face was verified successfully and your attendance has been marked.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.lg),

            // Verification confirmation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: AppSizes.iconSm + 2,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'Face verification successful',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go(AppRoutes.studentScanQrRoute);
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
