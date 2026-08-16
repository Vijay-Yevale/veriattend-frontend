import 'package:veriattend_app/core/model/face_profile_model.dart';

abstract class FaceRepository {
  Future<FaceProfileModel> enrollFace({required List<double> embedding});

  Future<FaceProfileModel?> getFaceProfile();

  Future<bool> checkFaceRegistration();
}
