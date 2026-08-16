import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/state/form_action_state.dart';
import 'package:veriattend_app/core/utils/action_handler.dart';
import 'package:veriattend_app/features/face/presentation/widgets/face_enrollement_success_view.dart';

import '../providers/face_action_provider.dart';
import '../widgets/face_camera_view.dart';

class FaceEnrollmentScreen extends ConsumerStatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  ConsumerState<FaceEnrollmentScreen> createState() =>
      _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends ConsumerState<FaceEnrollmentScreen> {
  bool _showSuccess = false;
  int _cameraAttempt = 0;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(faceActionProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<ActionState>(faceActionProvider, (previous, next) {
      handleActionState(
        context: context,
        state: next,
        onSuccess: () => setState(() => _showSuccess = true),
        onReset: () {
          ref.read(faceActionProvider.notifier).reset();

          setState(() => _cameraAttempt++);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Register Your Face')),

      body: SafeArea(
        child: _showSuccess
            ? FaceEnrollmentSuccessView(onContinue: () => context.pop())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      AppSizes.md,
                      AppSizes.lg,
                      AppSizes.sm,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security_rounded,
                            color: colorScheme.primary,
                            size: AppSizes.iconMd,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              'Your face will be used to securely verify attendance.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: FaceCameraView(
                      key: ValueKey(_cameraAttempt),
                      isSubmitting: actionState is ActionLoading,
                      onCaptured: (embedding) {
                        ref
                            .read(faceActionProvider.notifier)
                            .enrollFace(embedding: embedding);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
