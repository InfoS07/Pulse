import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/dialog_page.dart';
import 'package:pulse/core/router/app_router_listenable.dart';
import 'package:pulse/core/router/app_router_redirect.dart';
import 'package:pulse/core/router/scaffold_with_nav_bar.dart';
import 'package:pulse/features/activity/presentation/pages/activity_page.dart';
import 'package:pulse/features/activity/presentation/pages/save_activity_page.dart';
import 'package:pulse/features/auth/presentation/pages/login_page.dart';
import 'package:pulse/features/auth/presentation/pages/signup_page.dart';
import 'package:pulse/features/comments/presentation/pages/comments_page.dart';
import 'package:pulse/features/exercice_details/presentation/pages/exercice_page.dart';
import 'package:pulse/features/exercice_details/presentation/pages/modal_page.dart';
import 'package:pulse/features/exercices/presentation/pages/exercices_page.dart';
import 'package:pulse/features/home/presentation/pages/home_page.dart';
import 'package:pulse/features/likes/presentation/pages/likes_page.dart';
import 'package:pulse/features/post_details/presentation/pages/post_details_page.dart';
import 'package:pulse/features/profil/presentation/pages/profil_page.dart';
import 'package:pulse/features/profil_follow/presentation/pages/profil_follow_page.dart';
import 'package:pulse/features/profil_other/presentation/pages/profil_other_page.dart';
import 'package:pulse/features/progress/presentation/pages/progress_page.dart';
import 'package:pulse/features/screens/splash_screen.dart';
import 'package:pulse/init_dependencies.dart';

enum RoutePath {
  root(path: '/'),
  signIn(path: 'login'),
  home(path: 'home'),
  exercices(path: 'exercices'),
  progress(path: 'progress'),
  activity(path: 'activity'),
  saveActivity(path: 'save'),
  otherProfil(path: 'otherProfil'),
  follow(path: 'follow'),
  followOther(path: 'followOther'),
  profil(path: 'profil');

  const RoutePath({required this.path});
  final String path;
}

final GoRouter goRouterProvider = GoRouter(
  redirect: appRouterRedirect,
  refreshListenable: serviceLocator<AppRouterListenable>(),
  routes: [
    GoRoute(
      path: RoutePath.root.path,
      name: RoutePath.root.name,
      builder: (context, state) => SplashScreen(),
      routes: [
        GoRoute(
          path: RoutePath.signIn.path,
          name: RoutePath.signIn.name,
          builder: (context, state) => LoginPage(),
        ),
        GoRoute(
          path: RoutePath.otherProfil.path,
          name: RoutePath.otherProfil.name,
          builder: (context, state) => ProfilOtherPage(),
          routes: [
            GoRoute(
              path: RoutePath.followOther.path,
              name: RoutePath.followOther.name,
              builder: (context, state) => ProfilFollowPage(),
            ),
          ],
        ),
        GoRoute(
          path: RoutePath.activity.path,
          name: RoutePath.activity.name,
          pageBuilder: (context, state) => MaterialPage(
            key: ValueKey('ActivityPage'),
            fullscreenDialog: true,
            child: ActivityPage(),
          ),
          routes: [
            GoRoute(
              path: RoutePath.saveActivity.path,
              name: RoutePath.saveActivity.name,
              pageBuilder: (context, state) => MaterialPage(
                key: ValueKey('SaveActivityPage'),
                fullscreenDialog: true,
                child: SaveActivityPage(),
              ),
            ),
          ],
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ScaffoldWithNavBar(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePath.home.path,
                  name: RoutePath.home.name,
                  builder: (context, state) => HomePage(),
                  routes: [
                    GoRoute(
                      path: 'details/:postIndex',
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        final postIndex =
                            int.parse(state.pathParameters['postIndex']!);
                        return DialogPage(
                          builder: (_) => PostDetailsPage(postIndex: postIndex),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'comments',
                          builder: (context, state) => CommentsPage(),
                        ),
                        GoRoute(
                          path: 'likes',
                          builder: (context, state) => LikesPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePath.exercices.path,
                  name: RoutePath.exercices.name,
                  builder: (context, state) => ExercicesPage(),
                  routes: [
                    GoRoute(
                      path: 'details',
                      builder: (context, state) => ExercicePage(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePath.progress.path,
                  name: RoutePath.progress.name,
                  builder: (context, state) => ProgressPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePath.profil.path,
                  name: RoutePath.profil.name,
                  builder: (context, state) => ProfilPage(),
                  routes: [
                    GoRoute(
                      path: RoutePath.follow.path,
                      name: RoutePath.follow.name,
                      builder: (context, state) => ProfilFollowPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
