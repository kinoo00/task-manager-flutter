import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/constants/api_constants.dart';
import 'package:task_manager/data/models/user_model.dart';
import 'package:task_manager/data/services/api_client.dart';
import 'package:task_manager/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<({User user, String token})> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      final token = data['token'] as String;
      final user = User.fromJson(data['user']);
      await _saveAuthData(token, user);
      return (user: user, token: token);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<({User user, String token})> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      final data = response.data;
      final token = data['token'] as String;
      final user = User.fromJson(data['user']);
      await _saveAuthData(token, user);
      return (user: user, token: token);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${e.response?.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}