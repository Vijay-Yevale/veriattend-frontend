
class StudentInfoModel {
  final String studentId;
  final String userName;
  final String prn;

  const StudentInfoModel({
    required this.studentId,
    required this.userName,
    required this.prn,
  });

  factory StudentInfoModel.fromJson(Map<String, dynamic> json) {
    return StudentInfoModel(
      studentId: (json['studentId'] ?? json['_id']) as String,
      userName: json['userName'] as String,
      prn: json['PRN'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'studentId': studentId, 'userName': userName, 'PRN': prn};
  }
}
