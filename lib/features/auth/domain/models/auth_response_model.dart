import '../../../../core/model/user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;

  const AuthResponseModel({required this.user, required this.token});
}
