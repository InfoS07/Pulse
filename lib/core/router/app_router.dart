import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/router/app_router_listenable.dart';
import 'package:pulse/core/router/app_router_redirect.dart';
import 'package:pulse/core/router/scaffold_with_nav_bar.dart';
import 'package:pulse/features/auth/presentation/pages/login_page.dart';
import 'package:pulse/features/auth/presentation/pages/signup_page.dart';
import 'package:pulse/features/exercices/presentation/pages/exercices_page.dart';
import 'package:pulse/features/home/presentation/pages/home_page.dart';
import 'package:pulse/features/profil/presentation/pages/profil_page.dart';
import 'package:pulse/features/progress/presentation/pages/progress_page.dart';
import 'package:pulse/features/screens/splash_screen.dart';
import 'package:pulse/init_dependencies.dart';

enum RoutePath {
  root(path: '/'),
  signIn(path: 'login'),
  home(path: 'home'),
  exercices(path: 'exercices'),
  progress(path: 'progress'),
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
                      //pageBuilder: (context, state) => NoTransitionPage(child: child),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: RoutePath.exercices.path,
                      name: RoutePath.exercices.name,
                      builder: (context, state) => ExercicesPage(),
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
                    ),
                  ],
                ),
              ]),
        ]),
  ],
);
