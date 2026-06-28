import 'package:task_manager/data/models/project_model.dart';
import 'package:task_manager/data/models/task_model.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<List<Task>> getTasksForProject(int projectId);
  Future<Task> addTask(int projectId, String title, String priority, String status);
  Future<void> markTaskDone(int taskId);
  Future<Project> addProject(String title, String? description, String status);
}