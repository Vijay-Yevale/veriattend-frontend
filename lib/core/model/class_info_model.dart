class ClassInfoModel {
  final String classId;
  final String className;

  const ClassInfoModel({required this.classId, required this.className});

  factory ClassInfoModel.fromJson(Map<String, dynamic> json) {
    return ClassInfoModel(
      classId: (json['classId'] ?? json['_id']) as String,
      className: json['className'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'classId': classId, 'className': className};
  }
}
