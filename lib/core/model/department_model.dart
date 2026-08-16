// lib/features/auth/domain/models/department_model.dart

class DepartmentModel {
  final String id;
  final String name;
  final String code;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'code': code};
  }
}
