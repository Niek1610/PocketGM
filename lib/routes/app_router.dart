import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketgm/screens/bluetooth_screen.dart';
import 'package:pocketgm/screens/documentation_screen.dart';
import 'package:pocketgm/screens/game_screen.dart';
import 'package:pocketgm/screens/home_screen.dart';
import 'package:pocketgm/screens/openings_screen.dart';
import 'package:pocketgm/screens/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: '/game',
        pageBuilder: (context, state) => NoTransitionPage(child: GameScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            NoTransitionPage(child: SettingsScreen()),
      ),
      GoRoute(
        path: '/documentation',
        pageBuilder: (context, state) =>
            NoTransitionPage(child: DocumentationScreen()),
      ),
      GoRoute(
        path: '/bluetooth',
        pageBuilder: (context, state) =>
            NoTransitionPage(child: BluetoothScreen()),
      ),
      GoRoute(
        path: '/openings',
        pageBuilder: (context, state) =>
            NoTransitionPage(child: OpeningsScreen()),
      ),
    ],
  );
});
