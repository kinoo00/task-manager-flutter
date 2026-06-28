import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_manager/data/models/user_model.dart';
import 'package:task_manager/data/repositories/auth_repository_impl.dart';
import 'package:task_manager/data/services/api_client.dart';
import 'package:task_manager/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ApiClient());
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;

  AuthNotifier(this._authRepo) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepo.login(email, password);
      state = state.copyWith(user: result.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepo.register(name, email, password);
      state = state.copyWith(user: result.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> checkAuth() async {
    final user = await _authRepo.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    } else {
      state = state.copyWith(user: null);
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    state = AuthState(user: null, isLoading: false, error: null);
    print('🔴 User logged out, state cleared');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});