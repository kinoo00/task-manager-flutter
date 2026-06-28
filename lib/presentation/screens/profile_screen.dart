import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/presentation/providers/auth_provider.dart';
import 'package:task_manager/presentation/providers/theme_provider.dart';

import '../providers/project_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user != null) ...[
              CircleAvatar(
                radius: 50,
                child: Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 16),
              Text('Name: ${user.name}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
            ],
            // Dark mode toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (_) {
                ref.read(themeToggleProvider)();
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                ref.read(projectProvider.notifier).reset();
                if (context.mounted) {
                  context.replace('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}