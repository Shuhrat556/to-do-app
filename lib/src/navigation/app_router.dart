import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/settings_page.dart';
import '../presentation/statistics_page.dart';
import '../presentation/task_home_page.dart';

const _tabRoutes = ['/', '/statistics', '/settings'];

final GoRouter appRouter = GoRouter(
  initialLocation: _tabRoutes.first,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final index = _tabRoutes.indexWhere((path) => path == state.uri.path);
        final currentIndex = index == -1 ? 0 : index;
        return AppShell(currentIndex: currentIndex, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const TaskHomePage()),
        ),
        GoRoute(
          path: '/statistics',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const StatisticsPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const SettingsPage()),
        ),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const AppShell({super.key, required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Vazifalar'),
          NavigationDestination(
            icon: Icon(Icons.timeline),
            label: 'Statistika',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Sozlamalar',
          ),
        ],
        onDestinationSelected: (index) {
          context.go(_tabRoutes[index]);
        },
      ),
    );
  }
}
