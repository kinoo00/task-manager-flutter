import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/presentation/providers/auth_provider.dart';
import 'package:task_manager/presentation/screens/home_screen.dart';
import 'package:task_manager/presentation/screens/login_screen.dart';
import 'package:task_manager/presentation/screens/project_details_screen.dart';
import 'package:task_manager/presentation/screens/profile_screen.dart';
import 'package:task_manager/presentation/screens/register_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      print('🔀 Redirect check: isLoggedIn=$isLoggedIn, isAuthRoute=$isAuthRoute, location=${state.matchedLocation}');
      if (isLoggedIn && isAuthRoute) return '/home';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/project/:id',
        name: 'projectDetails',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProjectDetailsScreen(projectId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});