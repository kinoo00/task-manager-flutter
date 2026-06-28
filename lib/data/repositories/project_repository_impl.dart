import 'package:dio/dio.dart';
import 'package:task_manager/core/constants/api_constants.dart';
import 'package:task_manager/data/models/project_model.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/services/api_client.dart';
import 'package:task_manager/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ApiClient _apiClient;

  ProjectRepositoryImpl(this._apiClient);

  @override
  Future<List<Project>> getProjects() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.projects);
      final list = response.data as List;
      return list.map((e) => Project.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Task>> getTasksForProject(int projectId) async {
    try {
      final response = await _apiClient.dio.get(
          '${ApiConstants.tasks}/$projectId/tasks');
      final list = response.data as List;
      return list.map((e) => Task.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Task> addTask(int projectId, String title, String priority,
      String status) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.tasks}/$projectId/tasks',
        data: {'title': title, 'priority': priority, 'status': status},
      );
      return Task.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markTaskDone(int taskId) async {
    try {
      await _apiClient.dio.patch('/tasks/$taskId/done');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${e.response?.statusCode}';
    } else {
      return 'Network error: ${e.message}';
    }
  }

  @override
  Future<Project> addProject(String title, String? description,
      String status) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.projects,
        data: {'title': title, 'description': description, 'status': status},
      );
      return Project.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}