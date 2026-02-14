import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/presentation/providers/onboarding_provider.dart';
import 'package:pickture/presentation/screens/clean/clean_screen.dart';
import 'package:pickture/presentation/screens/clean/delete_queue_screen.dart';
import 'package:pickture/presentation/screens/clean/session_summary_screen.dart';
import 'package:pickture/presentation/screens/home/home_screen.dart';
import 'package:pickture/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:pickture/presentation/screens/settings/settings_screen.dart';
import 'package:pickture/presentation/screens/settings/trash_screen.dart';
import 'package:pickture/presentation/widgets/main_scaffold.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final onboardingCompleted = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      if (!onboardingCompleted && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
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
      GoRoute(
        path: '/trash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TrashScreen(),
      ),
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
