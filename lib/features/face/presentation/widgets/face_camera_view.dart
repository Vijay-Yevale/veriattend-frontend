import 'package:flutter/material.dart';

import 'package:veriattend_app/core/constants/app_colors.dart';
import 'package:veriattend_app/core/constants/app_sizes.dart';
import 'package:veriattend_app/core/constants/app_text_styles.dart';
import 'package:veriattend_app/core/widgets/app_error_widget.dart';
import 'package:veriattend_app/core/widgets/app_loader.dart';

import 'package:camera/camera.dart';
import 'package:face_detection_tflite/face_detection_tflite_native.dart'
    show rotationForFrame;
import 'package:veriattend_app/services/face_embedding_service.dart';

enum FaceCaptureStatus {
  initializingCamera,
  positionFace,
  faceDetected,
  holdStill,
  capturing,
  registering,
}

class FaceCameraView extends StatefulWidget {
  final void Function(List<double> embedding) onCaptured;
  final bool isSubmitting;

  const FaceCameraView({
    super.key,
    required this.onCaptured,
    this.isSubmitting = false,
  });

  @override
  State<FaceCameraView> createState() => _FaceCameraViewState();
}

class _FaceCameraViewState extends State<FaceCameraView> {
  static const _stableFramesRequired = 12;
  static const _minWidthFraction = 0.35;
  static const _maxWidthFraction = 0.8;
  static const _minScore = 0.8;

  CameraController? _cameraController;
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();

  FaceCaptureStatus _status = FaceCaptureStatus.initializingCamera;
  String? _errorMessage;

  bool _processingFrame = false;
  bool _capturedOnce = false;
  int _stableFrameCount = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _embeddingService.initialize();

      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _status = FaceCaptureStatus.positionFace;
      });

      await controller.startImageStream(_onFrame);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Could not start the camera. Check camera permission and try again.';
      });
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_processingFrame || _capturedOnce || widget.isSubmitting) return;
    _processingFrame = true;

    try {
      final controller = _cameraController;
      if (controller == null) return;

      final rotation = rotationForFrame(
        width: image.width,
        height: image.height,
        sensorOrientation: controller.description.sensorOrientation,
        isFrontCamera: true,
        deviceOrientation: controller.value.deviceOrientation,
      );

      final faces = await _embeddingService.detectFromCameraImage(
        image,
        rotation: rotation,
      );

      if (!mounted) return;

      if (faces.length != 1) {
        setState(() {
          _stableFrameCount = 0;
          _status = FaceCaptureStatus.positionFace;
        });
        return;
      }

      final face = faces.first;

      final wellPositioned =
          face.score >= _minScore &&
          face.widthFraction >= _minWidthFraction &&
          face.widthFraction <= _maxWidthFraction;

      if (!wellPositioned) {
        setState(() {
          _stableFrameCount = 0;
          _status = FaceCaptureStatus.faceDetected;
        });
        return;
      }

      _stableFrameCount++;

      if (_stableFrameCount < _stableFramesRequired) {
        setState(() {
          _status = FaceCaptureStatus.holdStill;
        });
        return;
      }

      _capturedOnce = true;

      setState(() {
        _status = FaceCaptureStatus.capturing;
      });

      await _captureAndEmbed();
    } finally {
      _processingFrame = false;
    }
  }

  Future<void> _captureAndEmbed() async {
    final controller = _cameraController;
    if (controller == null) return;

    try {
      await controller.stopImageStream();

      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();

      final embedding = await _embeddingService.generateEmbeddingFromStill(
        bytes,
      );

      if (!mounted) return;

      widget.onCaptured(embedding);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Could not capture your face clearly. Please try again.';
        _capturedOnce = false;
        _stableFrameCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _embeddingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: () {
          setState(() {
            _errorMessage = null;
            _capturedOnce = false;
            _stableFrameCount = 0;
          });

          _init();
        },
      );
    }

    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return const AppLoader();
    }

    final displayStatus = widget.isSubmitting
        ? FaceCaptureStatus.registering
        : _status;

    final previewSize = controller.value.previewSize;

    return Column(
      children: [
        const SizedBox(height: AppSizes.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.face_retouching_natural_rounded,
                  color: colorScheme.primary,
                  size: AppSizes.iconMd,
                ),
              ),

              const SizedBox(height: AppSizes.sm),

              Text(
                'Position your face in frame',
                style: AppTextStyles.titleLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.xs),

              Text(
                'Look directly at the camera and keep your face steady.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.lg),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (previewSize != null)
                    ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: previewSize.height,
                            height: previewSize.width,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                    ),

                  Container(color: Colors.black.withValues(alpha: 0.08)),

                  _FaceGuideOverlay(status: displayStatus),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.lg),

        _FaceStatusLabel(status: displayStatus),

        const SizedBox(height: AppSizes.xxl),
      ],
    );
  }
}

class _FaceGuideOverlay extends StatelessWidget {
  final FaceCaptureStatus status;

  const _FaceGuideOverlay({required this.status});

  Color _borderColor(BuildContext context) {
    switch (status) {
      case FaceCaptureStatus.faceDetected:
        return AppColors.warning;

      case FaceCaptureStatus.holdStill:
      case FaceCaptureStatus.capturing:
      case FaceCaptureStatus.registering:
        return AppColors.success;

      case FaceCaptureStatus.initializingCamera:
      case FaceCaptureStatus.positionFace:
        return Colors.white.withValues(alpha: 0.85);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _borderColor(context);

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 240,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: const BorderRadius.all(Radius.elliptical(120, 150)),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.20),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceStatusLabel extends StatelessWidget {
  final FaceCaptureStatus status;

  const _FaceStatusLabel({required this.status});

  String _label() {
    switch (status) {
      case FaceCaptureStatus.initializingCamera:
        return 'Initializing camera...';

      case FaceCaptureStatus.positionFace:
        return 'Position your face inside the frame';

      case FaceCaptureStatus.faceDetected:
        return 'Face detected — center it a little more';

      case FaceCaptureStatus.holdStill:
        return 'Hold still...';

      case FaceCaptureStatus.capturing:
        return 'Capturing...';

      case FaceCaptureStatus.registering:
        return 'Registering...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final showSpinner =
        status == FaceCaptureStatus.capturing ||
        status == FaceCaptureStatus.registering;

    final statusColor = switch (status) {
      FaceCaptureStatus.faceDetected => AppColors.warning,
      FaceCaptureStatus.holdStill => AppColors.success,
      FaceCaptureStatus.capturing => AppColors.primary,
      FaceCaptureStatus.registering => AppColors.primary,
      _ => colorScheme.onSurfaceVariant,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(status),
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: statusColor.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner) ...[
              const AppSmallLoader(color: AppColors.primary),
              const SizedBox(width: AppSizes.sm),
            ] else ...[
              Icon(
                status == FaceCaptureStatus.holdStill
                    ? Icons.check_circle_outline_rounded
                    : Icons.face_rounded,
                size: AppSizes.iconSm + 2,
                color: statusColor,
              ),
              const SizedBox(width: AppSizes.sm),
            ],

            Flexible(
              child: Text(
                _label(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
