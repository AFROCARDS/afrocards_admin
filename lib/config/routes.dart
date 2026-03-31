import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:afrocards_admin/shared/layouts/admin_layout.dart';
import 'package:afrocards_admin/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:afrocards_admin/features/auth/presentation/screens/login_screen.dart';
import 'package:afrocards_admin/features/users/presentation/screens/users_list_screen.dart';
import 'package:afrocards_admin/features/users/presentation/screens/users_roles_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // Login (sans layout admin)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Routes admin avec layout
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/partner-dashboard',
            name: 'partner-dashboard',
            builder: (context, state) => const _PlaceholderScreen(title: 'Dashboard Partenaire'),
          ),
          GoRoute(
            path: '/users',
            name: 'users',
            builder: (context, state) => const UsersListScreen(),
          ),
          GoRoute(
            path: '/users/roles',
            name: 'users-roles',
            builder: (context, state) => const UsersRolesScreen(),
          ),
          GoRoute(
            path: '/questions',
            name: 'questions',
            builder: (context, state) => const _PlaceholderScreen(title: 'Questions'),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const _PlaceholderScreen(title: 'Catégories'),
          ),
          GoRoute(
            path: '/challenges',
            name: 'challenges',
            builder: (context, state) => const _PlaceholderScreen(title: 'Challenges / Evenements'),
          ),
          GoRoute(
            path: '/wheel',
            name: 'wheel',
            builder: (context, state) => const _PlaceholderScreen(title: 'Roue Magique'),
          ),
          GoRoute(
            path: '/shop',
            name: 'shop',
            builder: (context, state) => const _PlaceholderScreen(title: 'Boutique'),
          ),
          GoRoute(
            path: '/partners',
            name: 'partners',
            builder: (context, state) => const _PlaceholderScreen(title: 'Partenaires'),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const _PlaceholderScreen(title: 'Paramètres'),
          ),
        ],
      ),
    ],
  );
}

// Widget temporaire pour les écrans non implémentés
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Écran en cours de développement',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
