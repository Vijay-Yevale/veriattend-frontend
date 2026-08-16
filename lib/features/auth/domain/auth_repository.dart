import '../../../core/model/user_model.dart';
import 'models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> register({
    required String userName,
    required String email,
    required String password,
    required String prn,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getMe();
}
