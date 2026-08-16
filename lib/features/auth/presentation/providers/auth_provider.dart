import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/model/user_model.dart';
import '../../data/auth_remote_datasource.dart';
import '../../data/auth_repository_impl.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepositoryImpl _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    return AuthInitial();
  }

  Future<void> checkAuth() async {
    state = AuthLoading();

    try {
      final user = await _repository.getMe();
      state = AuthAuthenticated(user);
    } on UnauthorizedFailure {
      state = AuthUnauthenticated();
    } on NetworkFailure catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = AuthUnauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = AuthLoading();

    try {
      final result = await _repository.login(email: email, password: password);

      state = AuthAuthenticated(result.user);
    } on UnauthorizedFailure catch (e) {
      state = AuthError(e.message);
    } on ValidationFailure catch (e) {
      state = AuthError(e.message);
    } on NetworkFailure catch (e) {
      state = AuthError(e.message);
    } on ServerFailure catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = AuthError('Something went wrong');
    }
  }

  Future<void> register({
    required String userName,
    required String email,
    required String password,
    required String prn,
  }) async {
    state = AuthLoading();

    try {
      final result = await _repository.register(
        userName: userName,
        email: email,
        password: password,
        prn: prn,
      );

      state = AuthAuthenticated(result.user);
    } on ConflictFailure catch (e) {
      state = AuthError(e.message);
    } on ValidationFailure catch (e) {
      state = AuthError(e.message);
    } on NetworkFailure catch (e) {
      state = AuthError(e.message);
    } on ServerFailure catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = AuthError('Something went wrong');
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthUnauthenticated();
  }

  void forceLogout() {
    if (state is! AuthUnauthenticated) {
      state = AuthUnauthenticated();
    }
  }
}

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthRemoteDatasource(dioClient);
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final datasource = ref.read(authRemoteDatasourceProvider);
  final secureStorage = ref.read(secureStorageProvider);

  return AuthRepositoryImpl(datasource, secureStorage);
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
