import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/common/entities/like.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/common/widgets/dialog_page.dart';
import 'package:pulse/core/router/app_router_listenable.dart';
import 'package:pulse/core/router/app_router_redirect.dart';
import 'package:pulse/core/router/scaffold_with_nav_bar.dart';
import 'package:pulse/features/activity/presentation/pages/activity_page.dart';
import 'package:pulse/features/activity/presentation/pages/save_activity_page.dart';
import 'package:pulse/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:pulse/features/auth/presentation/pages/login_page.dart';
import 'package:pulse/features/auth/presentation/pages/signup_page.dart';
import 'package:pulse/features/challenges/presentation/pages/challenge_activity_page.dart';
import 'package:pulse/features/challenges_users/domain/models/challenges_users_model.dart';
import 'package:pulse/features/challenges_users/presentation/pages/challenge_user_activity_page.dart';
import 'package:pulse/features/challenges_users/presentation/pages/challenges_users_details_page.dart';
import 'package:pulse/features/comments/presentation/pages/comments_page.dart';
import 'package:pulse/features/exercice_details/presentation/pages/exercice_page.dart';
import 'package:pulse/features/exercices/presentation/pages/exercices_page.dart';
import 'package:pulse/features/home/presentation/pages/home_page.dart';
import 'package:pulse/features/likes/presentation/pages/likes_page.dart';
import 'package:pulse/features/list_trainings/presentation/pages/list_trainings_page.dart';
import 'package:pulse/features/list_trainings/presentation/pages/my_post_details_page.dart';
import 'package:pulse/features/post_details/presentation/pages/post_details_page.dart';
import 'package:pulse/features/profil/presentation/pages/profil_page.dart';
import 'package:pulse/features/profil/presentation/pages/settings_page.dart';
import 'package:pulse/features/profil_follow/presentation/pages/profil_follow_page.dart';
import 'package:pulse/features/profil_other/presentation/pages/list_trainings_other_page.dart';
import 'package:pulse/features/profil_other/presentation/pages/profil_follow_other_page.dart';
import 'package:pulse/features/profil_other/presentation/pages/profil_other_page.dart';
import 'package:pulse/features/challenges/presentation/pages/challenges_page.dart';
import 'package:pulse/features/screens/introduction_slider.dart';
import 'package:pulse/features/screens/splash_screen.dart';
import 'package:pulse/features/search_users/presentation/pages/search_users_page.dart';
import 'package:pulse/init_dependencies.dart';

enum RoutePath {
  root(path: '/'),
  signIn(path: 'login'),
  signUp(path: 'signup'),
  forgotPasswordPage(path: 'forgot_password'),
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
  profil(path: 'profil'),
  settings(path: 'settings'),
  introSlider(path: 'intro-slider'),
  challengeUserDetails(path: 'challenges_users_details');

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
          path: RoutePath.forgotPasswordPage.path,
          name: RoutePath.forgotPasswordPage.name,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: RoutePath.signUp.path,
          name: RoutePath.signUp.name,
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: "activitychallenge",
          pageBuilder: (BuildContext context, GoRouterState state) {
            final Map<String, dynamic> extra =
                state.extra as Map<String, dynamic>;
            final Exercice exercise = extra['exercise'] as Exercice;
            final ChallengeUserModel challengeUser =
                extra['challengeUser'] as ChallengeUserModel;
            return DialogPage(
              builder: (_) => ActivityChallengeUserPage(exercise,
                  challengeUserModel: challengeUser),
            );
          },
        ),
        GoRoute(
          path: RoutePath.introSlider.path,
          name: RoutePath.introSlider.name,
          builder: (context, state) => IntroductionSliderPage(),
        ),
        GoRoute(
          path: RoutePath.otherProfil.path,
          name: RoutePath.otherProfil.name,
          builder: (context, state) =>
              ProfilOtherPage(userId: state.extra as String),
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
                  builder: (context, state) => HomePage(),
                  routes: [
                    GoRoute(
                      path: 'details/:postIndex',
                      builder: (context, state) {
                        final postIndex =
                            int.parse(state.pathParameters['postIndex']!);
                        return PostDetailsPage(postId: postIndex);
                      },
                      routes: [
                        GoRoute(
                          path: RoutePath.comments.path,
                          name: RoutePath.comments.name,
                          builder: (context, state) {
                            final postIndex =
                                int.parse(state.pathParameters['postIndex']!);
                            return CommentsPage(postId: postIndex);
                          },
                        ),
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
                      builder: (context, state) =>
                          ExercicePage(exercice: state.extra as Exercice),
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
                  routes: [
                    GoRoute(
                      path: RoutePath.challengeUserDetails.path,
                      name: RoutePath.challengeUserDetails.name,
                      builder: (context, state) => ChallengeUserDetailsPage(
                          challengeUser: state.extra as ChallengeUserModel),
                    ),
                  ],
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
                      path: RoutePath.settings.path,
                      name: RoutePath.settings.name,
                      builder: (context, state) => SettingsPage(),
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
                              builder: (_) => PostMyDetailsPage(post: post),
                            );
                          },
                        )
                      ],
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
