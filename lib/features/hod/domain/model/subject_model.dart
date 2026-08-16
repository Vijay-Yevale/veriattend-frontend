class SubjectModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final int semester;

  const SubjectModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.semester,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: (json['subjectId'] ?? json['_id']) as String,
      subjectName: json['subjectName'] as String,
      subjectCode: json['subjectCode'] as String,
      semester: (json['semester'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': subjectId,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'semester': semester,
    };
  }
}
