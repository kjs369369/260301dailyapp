import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../../features/habits/presentation/habit_management_screen.dart';
import '../../features/journal/presentation/journal_editor_screen.dart';
import '../widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'journal/:date',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final dateStr = state.pathParameters['date']!;
                    final date = DateTime.parse(dateStr);
                    return JournalEditorScreen(date: date);
                  },
                ),
                GoRoute(
                  path: 'manage-habits',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const HabitManagementScreen(),
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Calendar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
              routes: [
                GoRoute(
                  path: 'journal/:date',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final dateStr = state.pathParameters['date']!;
                    final date = DateTime.parse(dateStr);
                    return JournalEditorScreen(date: date);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Statistics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
        // Tab 4: Settings (Habit Management)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) =>
                  const HabitManagementScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
