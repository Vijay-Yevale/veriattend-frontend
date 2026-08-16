// lib/core/model/face_profile_model.dart

class FaceProfileModel {
  final String id;
  final String studentId;
  final String modelName;
  final String modelVersion;
  final String? createdAt;
  final String? updatedAt;

  const FaceProfileModel({
    required this.id,
    required this.studentId,
    required this.modelName,
    required this.modelVersion,
    this.createdAt,
    this.updatedAt,
  });

  factory FaceProfileModel.fromJson(Map<String, dynamic> json) {
    return FaceProfileModel(
      id: json['_id'] as String,
      studentId: json['studentId'] as String,
      modelName: json['modelName'] as String,
      modelVersion: json['modelVersion'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentId': studentId,
      'modelName': modelName,
      'modelVersion': modelVersion,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
