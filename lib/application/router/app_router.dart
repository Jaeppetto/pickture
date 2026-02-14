import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/presentation/screens/clean/clean_screen.dart';
import 'package:pickture/presentation/screens/clean/delete_queue_screen.dart';
import 'package:pickture/presentation/screens/clean/session_summary_screen.dart';
import 'package:pickture/presentation/screens/home/home_screen.dart';
import 'package:pickture/presentation/screens/settings/settings_screen.dart';
import 'package:pickture/presentation/widgets/main_scaffold.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/clean',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CleanScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      // Full-screen routes (outside shell/tab bar)
      GoRoute(
        path: '/delete-queue/:sessionId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return DeleteQueueScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/session-summary/:sessionId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return SessionSummaryScreen(sessionId: sessionId);
        },
      ),
    ],
  );
}
