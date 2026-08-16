class TeacherModel {
  final String teacherId;
  final String userName;

  const TeacherModel({required this.teacherId, required this.userName});

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      teacherId: (json['teacherId'] ?? json['_id']) as String,
      userName: json['userName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'teacherId': teacherId, 'userName': userName};
  }
}
