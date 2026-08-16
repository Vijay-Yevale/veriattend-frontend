import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/models/auth_response_model.dart';
import '../../../core/model/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(this._datasource, this._secureStorage);

  //  Register
  @override
  Future<AuthResponseModel> register({
    required String userName,
    required String email,
    required String password,
    required String prn,
  }) async {
    try {
      final result = await _datasource.register(
        userName: userName,
        email: email,
        password: password,
        prn: prn,
      );

      await _secureStorage.saveAuthData(
        token: result.token,
        userId: result.user.id,
        role: result.user.role,
      );

      return result;
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw _mapStatusCodeToFailure(e);
    }
  }

  //  Login
  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      print("STEP 1");
      final result = await _datasource.login(email: email, password: password);
      print("STEP 2");
      // save token + userId + role after successful login
      await _secureStorage.saveAuthData(
        token: result.token,
        userId: result.user.id,
        role: result.user.role,
      );
      print("STEP 3");
      print(await _secureStorage.getToken());
      print("STEP 4");
      return result;
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw _mapStatusCodeToFailure(e);
    }
  }

  // add to auth_repository_impl.dart
  @override
  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  //  Get Me
  @override
  Future<UserModel> getMe() async {
    try {
      return await _datasource.getMe();
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw _mapStatusCodeToFailure(e);
    }
  }

  Failure _mapStatusCodeToFailure(ServerException e) {
    switch (e.statusCode) {
      case 400:
        return ValidationFailure(message: e.message);
      case 401:
        return UnauthorizedFailure(message: e.message);
      case 404:
        return NotFoundFailure(message: e.message);
      case 409:
        return ConflictFailure(message: e.message);
      default:
        return ServerFailure(message: e.message);
    }
  }
}
