import 'package:veriattend_app/core/model/department_model.dart';
import 'package:veriattend_app/core/model/user_model.dart';

abstract class AdminRepository {
  Future<List<DepartmentModel>> getDepartments();

  Future<DepartmentModel> createDepartment({
    required String name,
    required String code,
  });

  Future<UserModel> createHod({
    required String userName,
    required String email,
    required String password,
    required String departmentId,
  });
}
