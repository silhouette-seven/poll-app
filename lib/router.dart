import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poll_app/features/common/animated_wave_background.dart';
import 'package:poll_app/features/polls/presentation/screens/polls_list_screen.dart';
import 'package:poll_app/features/polls/presentation/screens/create_poll_screen.dart';

// ShellRoute for bottom navigation bar
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PollsListScreen(),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreatePollScreen(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWaveBackground(child: child),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if (index == 0) {
            context.go('/');
          } else {
            context.go('/create');
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.poll_outlined),
            selectedIcon: Icon(Icons.poll),
            label: 'Polls',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/create') {
      return 1;
    }
    return 0;
  }
}
