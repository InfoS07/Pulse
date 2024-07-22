import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/formatters.dart';
import 'package:pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';
import 'package:pulse/features/comments/presentation/bloc/comment_bloc.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/list_trainings/presentation/bloc/list_trainings_bloc.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';
import 'package:pulse/features/profil_other/presentation/bloc/profil_other_bloc.dart';
import 'package:pulse/features/search_users/presentation/bloc/search_users_bloc.dart';
import 'package:pulse/firebase_options.dart';
import 'package:pulse/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  await initializeDateFormattingForLocale();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  OneSignal.initialize("300b20c3-d537-46ee-b600-aca8dd2c8ae4");
  OneSignal.Notifications.requestPermission(true);

  runZonedGuarded<Future<void>>(() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => serviceLocator<AppUserCubit>(),
                ),
                BlocProvider(
                  create: (_) => serviceLocator<AuthBloc>(),
                ),
                BlocProvider(create: (_) => serviceLocator<HomeBloc>()),
                BlocProvider(create: (_) => serviceLocator<CommentBloc>()),
                BlocProvider(create: (_) => serviceLocator<ProfilBloc>()),
                BlocProvider(create: (_) => serviceLocator<ExercicesBloc>()),
                BlocProvider(create: (_) => serviceLocator<ActivityBloc>()),
                BlocProvider(create: (_) => serviceLocator<OtherProfilBloc>()),
                BlocProvider(create: (_) => serviceLocator<ProfilFollowBloc>()),
                BlocProvider(
                    create: (_) => serviceLocator<ListTrainingsBloc>()),
                BlocProvider(create: (_) => serviceLocator<SearchUsersBloc>()),
                BlocProvider(create: (_) => serviceLocator<ChallengesBloc>()),
                BlocProvider(
                    create: (_) => serviceLocator<ChallengesUsersBloc>()),
                BlocProvider(create: (_) => serviceLocator<SearchUsersBloc>())
              ],
              child: const MyApp(),
            )));
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  void _crash() {
    throw Exception("WAHOU, voici un beau test de bug !");
  }

  @override
  Widget build(BuildContext context) {
    //router provider
    final appRouter = serviceLocator<GoRouter>();
    //_crash();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Pulse App',
      theme: ThemeData(
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppPallete.primaryColor,
          secondary: Colors.greenAccent,
        ),
        scaffoldBackgroundColor: Colors.black, //AppPallete.backgroundColor
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: AppPallete.backgroundColor,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.primaryColor,
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38.0),
            side: const BorderSide(
              color: AppPallete.backgroundColor,
            ),
          ),
          backgroundColor: AppPallete.backgroundColor,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
