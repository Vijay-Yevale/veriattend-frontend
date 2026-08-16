class AvailableSubjectModel {
  final String subjectId;
  final String subjectName;
  final String subjectCode;

  const AvailableSubjectModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
  });

  factory AvailableSubjectModel.fromJson(Map<String, dynamic> json) {
    return AvailableSubjectModel(
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      subjectCode: json['subjectCode'] as String,
    );
  }
}
