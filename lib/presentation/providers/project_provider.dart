import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_manager/data/models/project_model.dart';
import 'package:task_manager/data/repositories/project_repository_impl.dart';
import 'package:task_manager/data/services/api_client.dart';
import 'package:task_manager/domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(ApiClient());
});

class ProjectsState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final bool initialFetchDone;   // 👈 new flag

  ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
    this.initialFetchDone = false,
  });

  ProjectsState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
    bool? initialFetchDone,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      initialFetchDone: initialFetchDone ?? this.initialFetchDone,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectsState> {
  final ProjectRepository _repo;

  ProjectNotifier(this._repo) : super(ProjectsState());

  Future<void> fetchProjects({bool force = false}) async {
    // Skip if already fetched once and not forcing refresh
    if (state.initialFetchDone && !force) {
      print('⏭️ Projects already fetched, skipping (force=$force)');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _repo.getProjects();
      state = state.copyWith(
        projects: projects,
        isLoading: false,
        initialFetchDone: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        initialFetchDone: true, // mark as done even on error
      );
    }
  }

  Future<void> addProject(String title, String? description, String status) async {
    try {
      final project = await _repo.addProject(title, description, status);
      // Add to local list
      final updatedList = [...state.projects, project];
      state = state.copyWith(projects: updatedList);
    } catch (e) {
      // Optionally set error state
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  void reset() {
    state = ProjectsState(); // clears projects, loading, error
    print('🗑️ Projects reset');
  }

}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectsState>((ref) {
  return ProjectNotifier(ref.read(projectRepositoryProvider));
});