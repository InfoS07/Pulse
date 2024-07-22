import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/exercices/presentation/bloc/exercices_bloc.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/home/presentation/widgets/achievement_badge_widget.dart';
import 'package:pulse/features/home/presentation/widgets/exercice_card_widget.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/week_days_widget.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Utilisateur"; // Nom par défaut
  String urlProfilePhoto = "";
  int points = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadPosts());
    context.read<ExercicesBloc>().add(ExercicesLoad());

    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userName = authState.user.firstName + " " + authState.user.lastName;
      urlProfilePhoto = authState.user.urlProfilePhoto;
      points = authState.user.points;
    }
  }

  void _updateUserInfo() {
    context.read<AuthBloc>().add(AuthReloadUser());
    final authState = context.read<AppUserCubit>().state;

    if (authState is AppUserLoggedIn) {
      setState(() {
        userName = authState.user.firstName + " " + authState.user.lastName;
        urlProfilePhoto = authState.user.urlProfilePhoto;
        points = authState.user.points;
      });
    }
  }

  Future<void> _refreshPosts() async {
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
    _updateUserInfo();
  }

  String getTotalTimeForMyPosts(List<SocialMediaPost> posts) {
    final totalTime = posts.fold(
        0,
        (previousValue, post) =>
            previousValue + post.endAt.difference(post.startAt).inMinutes);
    final hours = totalTime ~/ 60;
    final minutes = totalTime % 60;
    return '$hours h $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: CachedNetworkImage(
                    imageUrl: urlProfilePhoto,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 40),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bonjour',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                context.push('/home/searchUser');
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                context.push('/home/calendar');
              },
            ),
            const Stack(
              children: [
                // Commented out notification icon for now
                // IconButton(
                //   icon: const Icon(Icons.notifications),
                //   onPressed: () {},
                // ),
                // Positioned(
                //   right: 11,
                //   top: 11,
                //   child: Container(
                //     padding: const EdgeInsets.all(2),
                //     decoration: BoxDecoration(
                //       color: Colors.red,
                //       borderRadius: BorderRadius.circular(6),
                //     ),
                //     constraints: const BoxConstraints(
                //       minWidth: 12,
                //       minHeight: 12,
                //     ),
                //     child: const Text(
                //       '5',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 8,
                //       ),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
        body: BlocListener<ProfilBloc, ProfilState>(
          listener: (context, state) {
            if (state is ProfilSuccess) {
              _refreshPosts();
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 32),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[600]!,
                          highlightColor: Colors.grey[200]!,
                          child: Container(
                            width: 300,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 32),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                        child: Text(
                          "Recommendations",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[600]!,
                          highlightColor: Colors.grey[200]!,
                          child: Container(
                            width: 300,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 32),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                        child: Text(
                          "Entrainements",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[600]!,
                            highlightColor: Colors.grey[200]!,
                            child: Container(
                              height: 150,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        childCount: 5, // Number of shimmer items
                      ),
                    ),
                  ],
                );
              } else if (state is HomeLoaded) {
                return RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                      SliverToBoxAdapter(
                        child: AchievementBadgeWidget(
                          message: 'Vous avez ${points} points',
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12),
                          child: Text(
                            "Recommendations",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200, // Ajustez cette valeur selon vos besoins
                          child: BlocBuilder<ExercicesBloc, ExercicesState>(
                            builder: (context, exercisesState) {
                              if (exercisesState is ExercicesLoaded) {
                                return Swiper(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final exercise = exercisesState
                                        .exercisesByCategory.values
                                        .expand((ex) => ex)
                                        .toList()[index];
                                    return ExerciseHomeCardWidget(
                                      imageUrl: exercise!.photos.first,
                                      title: exercise.title,
                                      onStart: () {
                                        context.push(
                                            '/exercices/details/${exercise.id}',
                                            extra: exercise);
                                      },
                                    );
                                  },
                                  itemCount: exercisesState
                                      .exercisesByCategory.values
                                      .expand((ex) => ex)
                                      .length,
                                  itemWidth: 350.0,
                                  layout: SwiperLayout.STACK,
                                );
                              } else if (exercisesState is ExercicesLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                return const Center(
                                    child: Text('Aucun exercice trouvé'));
                              }
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12),
                          child: Text(
                            "Entrainements",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (!state.posts.isEmpty) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: SocialMediaPostWidget(
                                  post: state.posts[index]!,
                                  onTap: () {
                                    context.push('/home/details/$index',
                                        extra: state.posts[index]);
                                  },
                                ),
                              );
                            }
                          },
                          childCount: state.posts.length,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is HomeError) {
                return _buildErrorScreen(context, state.message);
              } else if (state is HomeEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                      SliverToBoxAdapter(
                        child: AchievementBadgeWidget(
                          message: 'Vous avez 0 points',
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12),
                          child: Text(
                            "Recommendations",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200, // Ajustez cette valeur selon vos besoins
                          child: BlocBuilder<ExercicesBloc, ExercicesState>(
                            builder: (context, exercisesState) {
                              if (exercisesState is ExercicesLoaded) {
                                return Swiper(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final exercise = exercisesState
                                        .exercisesByCategory.values
                                        .expand((ex) => ex)
                                        .toList()[index];
                                    return ExerciseHomeCardWidget(
                                      imageUrl: exercise!.photos.first,
                                      title: exercise.title,
                                      onStart: () {
                                        context.push(
                                            '/exercices/details/${exercise.id}',
                                            extra: exercise);
                                      },
                                    );
                                  },
                                  itemCount: exercisesState
                                      .exercisesByCategory.values
                                      .expand((ex) => ex)
                                      .length,
                                  itemWidth: 350.0,
                                  layout: SwiperLayout.STACK,
                                );
                              } else if (exercisesState is ExercicesLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                return const Center(
                                    child: Text('Aucun exercice trouvé'));
                              }
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 80),
                      ),
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage('assets/images/cloud.png'),
                                width: 150,
                              ),
                              SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 60.0),
                                child: Text(
                                  'Vous n\'avez aucune aucun entraînement pour le moment.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text('Unknown state'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Impossible de charger cette page.',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<HomeBloc>(context).add(LoadPosts());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Réessayer',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
