import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_detection_tflite/face_detection_tflite_native.dart';

class FaceEmbeddingService {
  FaceDetector? _detector;

  Future<void> initialize() async {
    _detector ??= await FaceDetector.create(
      model: FaceDetectionModel.frontCamera,
      minFacePresenceConfidence: 0.5,
    );
  }

  Future<List<Face>> detectFromCameraImage(
    CameraImage image, {
    required CameraFrameRotation? rotation,
    int maxDim = 640,
  }) {
    final detector = _detector;
    if (detector == null) {
      throw StateError('FaceEmbeddingService.initialize() was not called.');
    }

    return detector.detectFacesFromCameraImage(
      image,
      rotation: rotation,
      mode: FaceDetectionMode.fast,
      maxDim: maxDim,
    );
  }

  Future<List<double>> generateEmbeddingFromStill(Uint8List stillBytes) async {
    final detector = _detector;
    if (detector == null) {
      throw StateError('FaceEmbeddingService.initialize() was not called.');
    }

    final faces = await detector.detectFacesFromBytes(
      stillBytes,
      mode: FaceDetectionMode.full,
    );

    if (faces.isEmpty) {
      throw StateError('No face detected in the captured photo.');
    }
    if (faces.length > 1) {
      throw StateError('More than one face detected in the captured photo.');
    }

    final embedding = await detector.getFaceEmbedding(faces.first, stillBytes);
    return embedding.toList().cast<double>();
  }

  Future<void> dispose() async {
    await _detector?.dispose();
    _detector = null;
  }
}
