class SubjectInfoModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;

  const SubjectInfoModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
  });

  factory SubjectInfoModel.fromJson(Map<String, dynamic> json) {
    return SubjectInfoModel(
      subjectId: (json['subjectId'] ?? json['_id']) as String,
      subjectName: json['subjectName'] as String,
      subjectCode: json['subjectCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
    };
  }
}
