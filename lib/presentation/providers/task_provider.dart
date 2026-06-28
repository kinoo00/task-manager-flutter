import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/repositories/project_repository_impl.dart';
import 'package:task_manager/data/services/api_client.dart';
import 'package:task_manager/domain/repositories/project_repository.dart';

final taskRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(ApiClient());
});

class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  TasksState({this.tasks = const [], this.isLoading = false, this.error});

  TasksState copyWith({List<Task>? tasks, bool? isLoading, String? error}) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TaskNotifier extends StateNotifier<TasksState> {
  final ProjectRepository _repo;
  final int projectId;

  TaskNotifier(this._repo, this.projectId) : super(TasksState());

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repo.getTasksForProject(projectId);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addTask(String title, String priority, String status) async {
    try {
      final task = await _repo.addTask(projectId, title, priority, status);
      // Add to local list
      final updatedList = [...state.tasks, task];
      state = state.copyWith(tasks: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> markDone(int taskId) async {
    try {
      await _repo.markTaskDone(taskId);
      // Update local state
      final updatedTasks = state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(status: 'Done');
        }
        return t;
      }).toList();
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final taskProvider = StateNotifierProvider.family<TaskNotifier, TasksState, int>(
      (ref, projectId) {
    final repo = ref.read(taskRepositoryProvider);
    return TaskNotifier(repo, projectId)..fetchTasks();
  },
);