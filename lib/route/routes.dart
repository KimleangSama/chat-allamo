import 'package:chat_allamo/screen/about_dev_screen.dart';
import 'package:chat_allamo/screen/ollama_model_list_detail_screen.dart';
import 'package:chat_allamo/screen/favorite_archive_screen.dart';
import 'package:chat_allamo/screen/image_viewer_screen.dart';
import 'package:chat_allamo/screen/request_new_model_screen.dart';
import 'package:chat_allamo/screen/scaffold_with_nested_navigation.dart';
import 'package:chat_allamo/screen/settings/data_controls_screen.dart';
import 'package:chat_allamo/screen/settings/ollama_configuration_screen.dart';
import 'package:chat_allamo/screen/setting_preference_screen.dart';
import 'package:chat_allamo/screen/zoom_drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// GoRouter configuration
final mainRouters = GoRouter(
  initialLocation: '/chat',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ZoomDrawerScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: FavoriteArchiveScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/models',
              pageBuilder: (context, state) => NoTransitionPage(
                child: OllamaModelListDetailScreen(),
              ),
              routes: [
                GoRoute(
                  name: 'request_new_model',
                  path: 'request_new_model',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: RequestNewModelScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/info',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AboutDevScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SettingPreferenceScreen(),
      ),
      routes: [
        GoRoute(
          name: 'data_controls',
          path: 'data_controls',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DataControlsScreen(),
          ),
        ),
        GoRoute(
          name: 'configurations',
          path: 'configurations',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: OllamaConfigurationScreen(),
          ),
        )
      ],
    ),
    GoRoute(
      name: 'image_viewer',
      path: '/image_viewer/:imageURL',
      pageBuilder: (context, state) => NoTransitionPage(
        child: ImageViewerScreen(imageUrl: state.pathParameters['imageURL']!),
      ),
    ),
  ],
);
