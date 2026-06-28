import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/presentation/providers/task_provider.dart';
import 'package:task_manager/presentation/widgets/empty_state.dart';
import 'package:task_manager/presentation/widgets/loading_shimmer.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';
import 'package:task_manager/presentation/widgets/add_task_bottom_sheet.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final int projectId;
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // The taskProvider family already fetches on creation.
  }

  Future<void> _refresh() async {
    final notifier = ref.read(taskProvider(widget.projectId).notifier);
    await notifier.fetchTasks();
    // We can also call fetchTasks directly if we expose a method.
    // We'll add a method in the notifier later.
    // For now, we'll use ref.refresh to rebuild and fetch again.
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(taskProvider(widget.projectId));
    final tasks = tasksState.tasks;
    final isLoading = tasksState.isLoading;
    final error = tasksState.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => AddTaskBottomSheet(projectId: widget.projectId),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? const LoadingShimmer()
            : error != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : tasks.isEmpty
            ? const EmptyState(
          icon: Icons.task,
          message: 'No tasks in this project',
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              onMarkDone: () async {
                if (task.status != 'Done') {
                  await ref
                      .read(taskProvider(widget.projectId).notifier)
                      .markDone(task.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}