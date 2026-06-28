import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/presentation/providers/project_provider.dart';
import 'package:task_manager/presentation/providers/refresh_provider.dart';
import 'package:task_manager/presentation/widgets/empty_state.dart';
import 'package:task_manager/presentation/widgets/loading_shimmer.dart';
import 'package:task_manager/presentation/widgets/add_project_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First fetch (will skip if already done via state flag)
      ref.read(projectProvider.notifier).fetchProjects();
      triggerRefresh(ref);
    });
  }

  Future<void> _refresh() async {
    // Force refresh on pull‑to‑refresh
    await ref.read(projectProvider.notifier).fetchProjects(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final projects = projectState.projects;
    final isLoading = projectState.isLoading;
    final error = projectState.error;

    // 🔁 Listen to refresh trigger and fetch when it changes
    ref.listen<int>(refreshTriggerProvider, (previous, next) {
      if (next != previous) {
        ref.read(projectProvider.notifier).fetchProjects(force: true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
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
            : projects.isEmpty
            ? const EmptyState(
          icon: Icons.folder_open,
          message: 'No projects yet',
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Hero(
                  tag: 'project-${project.id}',
                  child: CircleAvatar(
                    child: Text(project.title[0].toUpperCase()),
                  ),
                ),
                title: Text(project.title),
                subtitle: project.description != null
                    ? Text(project.description!)
                    : null,
                trailing: Chip(
                  label: Text(
                    project.status,
                    style: const TextStyle(color: Colors.black),
                  ),
                  backgroundColor: project.status == 'Active'
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                ),
                onTap: () {
                  context.go('/project/${project.id}', extra: project.title);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddProjectBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}