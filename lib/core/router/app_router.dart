import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/like.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
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
import 'package:pulse/features/exercices/presentation/pages/exercices_page.dart';
import 'package:pulse/features/home/presentation/pages/home_page.dart';
import 'package:pulse/features/likes/presentation/pages/likes_page.dart';
import 'package:pulse/features/list_trainings/presentation/pages/list_trainings_page.dart';
import 'package:pulse/features/post_details/presentation/pages/post_details_page.dart';
import 'package:pulse/features/profil/presentation/pages/profil_page.dart';
import 'package:pulse/features/profil_follow/presentation/pages/profil_follow_page.dart';
import 'package:pulse/features/profil_other/presentation/pages/list_trainings_other_page.dart';
import 'package:pulse/features/profil_other/presentation/pages/profil_follow_other_page.dart';
import 'package:pulse/features/profil_other/presentation/pages/profil_other_page.dart';
import 'package:pulse/features/challenges/presentation/pages/challenges_page.dart';
import 'package:pulse/features/screens/splash_screen.dart';
import 'package:pulse/features/search_users/presentation/pages/search_users_page.dart';
import 'package:pulse/init_dependencies.dart';

enum RoutePath {
  root(path: '/'),
  signIn(path: 'login'),
  signUp(path: 'signup'),
  home(path: 'home'),
  exercices(path: 'exercices'),
  progress(path: 'progress'),
  activity(path: 'activity'),
  comments(path: 'comments'),
  saveActivity(path: 'save'),
  otherProfil(path: 'otherProfil'),
  follow(path: 'follow'),
  followOther(path: 'followOther'),
  searchUser(path: 'searchUser'),
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
      builder: (context, state) => const SplashScreen(),
      routes: [
        GoRoute(
          path: RoutePath.signIn.path,
          name: RoutePath.signIn.name,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: RoutePath.signUp.path,
          name: RoutePath.signUp.name,
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: RoutePath.otherProfil.path,
          name: RoutePath.otherProfil.name,
          pageBuilder: (BuildContext context, GoRouterState state) {
            final userId = state.extra as String;
            return DialogPage(
              builder: (_) => ProfilOtherPage(userId: userId),
            );
          },
          routes: [
            GoRoute(
              path: RoutePath.followOther.path,
              name: RoutePath.followOther.name,
              pageBuilder: (BuildContext context, GoRouterState state) {
                final userIdOther = state.extra as String;
                return DialogPage(
                  builder: (_) =>
                      OtherProfilFollowPage(userIdOther: userIdOther),
                );
              },
            ),
            GoRoute(
              path: 'entrainementsOther',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final userId = state.extra as String;
                return DialogPage(
                  builder: (_) => TrainingListOtherScreen(userId: userId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: RoutePath.activity.path,
          name: RoutePath.activity.name,
          pageBuilder: (context, state) => MaterialPage(
            key: const ValueKey('ActivityPage'),
            fullscreenDialog: true,
            child: ActivityPage(state.extra as Exercice),
          ),
          routes: [
            GoRoute(
              path: RoutePath.saveActivity.path,
              name: RoutePath.saveActivity.name,
              pageBuilder: (context, state) => const MaterialPage(
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
                  builder: (context, state) => const HomePage(),
                  routes: [
                    GoRoute(
                      path: 'details/:postIndex',
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        final post = state.extra as SocialMediaPost;
                        return DialogPage(
                          builder: (_) => PostDetailsPage(post: post),
                        );
                      },
                      routes: [
                        GoRoute(
                            path: RoutePath.comments.path,
                            name: RoutePath.comments.name,
                            builder: (context, state) => CommentsPage(
                                post: state.extra as SocialMediaPost)),
                        GoRoute(
                          path: 'likes',
                          builder: (context, state) =>
                              LikesPage(likes: state.extra as List<Like>),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: RoutePath.searchUser.path,
                      name: RoutePath.searchUser.name,
                      builder: (context, state) => SearchUsersPage(),
                      /* builder: (context, state) => DialogPage(
                          builder: (_) => SearchUsersPage(),
                        );, */
                    )
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePath.exercices.path,
                  name: RoutePath.exercices.name,
                  builder: (context, state) => const ExercicesPage(),
                  routes: [
                    GoRoute(
                      path: 'details/:exerciceIndex',
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        /* final exerciceIndex =
                            int.parse(state.pathParameters['exerciceIndex']!); */
                        final exercice = state.extra as Exercice;
                        return DialogPage(
                          builder: (_) => ExercicePage(exercice: exercice),
                        );
                      },
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
                  builder: (context, state) => GroupPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: RoutePath.profil.path,
                  name: RoutePath.profil.name,
                  builder: (context, state) => const ProfilPage(),
                  routes: [
                    GoRoute(
                      path: RoutePath.follow.path,
                      name: RoutePath.follow.name,
                      builder: (context, state) => const ProfilFollowPage(),
                    ),
                    GoRoute(
                        path: 'entrainements',
                        builder: (context, state) => TrainingListScreen(),
                        routes: [
                          GoRoute(
                            path: 'details/:postIndex',
                            pageBuilder:
                                (BuildContext context, GoRouterState state) {
                              final post = state.extra as SocialMediaPost;
                              return DialogPage(
                                builder: (_) => PostDetailsPage(post: post),
                              );
                            },
                          )
                        ]),
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
