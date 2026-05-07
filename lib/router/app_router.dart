import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/place.dart';
import '../presentation/screens/detail_screen.dart';
import '../presentation/screens/favorites_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/map_screen.dart';
import '../presentation/screens/placeholder_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/search_filter_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/widgets/main_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: 'map',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(
                  child: MapScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(
                  child: FavoritesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/detail/:id',
        name: 'detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Place) {
            return const Scaffold(
              body: Center(child: Text('Missing place data')),
            );
          }
          return DetailScreen(place: extra);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchFilterScreen(),
      ),
      GoRoute(
        path: '/downloaded',
        name: 'downloaded',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Downloaded',
          subtitle: 'Offline saved trips would appear here.',
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Settings',
          subtitle: 'Configure notifications and preferences.',
        ),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Help & Support',
          subtitle: 'Contact support@smarttravel.example',
        ),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const PlaceholderScreen(
          title: 'About Us',
          subtitle: 'Smart Travel Companion — academic demo.',
        ),
      ),
    ],
  );
});
