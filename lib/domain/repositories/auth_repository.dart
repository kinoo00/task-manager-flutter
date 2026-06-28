import 'package:task_manager/data/models/user_model.dart';

abstract class AuthRepository {
  Future<({User user, String token})> login(String email, String password);
  Future<({User user, String token})> register(String name, String email, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();
}