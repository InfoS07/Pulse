import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/daily_stats.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/home/presentation/widgets/achievement_badge_widget.dart';
import 'package:pulse/features/home/presentation/widgets/recommend_exercise_card_widget.dart';
import 'package:pulse/features/home/presentation/widgets/session_card_widget.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:redacted/redacted.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Utilisateur"; // Nom par défaut
  String urlProfilePhoto = "";

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());

    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      print("authState.user : ${authState.user.uid}");
      userName = authState.user.firstName + " " + authState.user.lastName;
      urlProfilePhoto = authState.user.urlProfilePhoto;
    }
  }

  Future<void> _refreshPosts() async {
    /* OneSignal.InAppMessages.addTrigger("defis", "2");
    OneSignal.Notifications.addClickListener((event) {
      print('Key: ${event.notification.title}');
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
    }); */
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
  }

  final List<DailyStats> dailyStats = [
    DailyStats(label: 'Entrainements', value: '0', trend: '0'),
    DailyStats(label: 'Temps', value: '0h 0min', trend: '0h 0min'),
    // Ajoutez d'autres statistiques si nécessaire
  ];

  final List<RecommendExerciseCardWidget> recommendedExercises = [
    RecommendExerciseCardWidget(
      imageUrl:
          'https://cdn.dribbble.com/userupload/13994781/file/original-aa936ab9619914b7debecd452b772624.jpg?resize=1600x1200',
      title: 'Body wellness and performance program',
      subtitle: '',
      duration: '10 minutes',
      pods: '2 pods',
    ),
    RecommendExerciseCardWidget(
      imageUrl:
          'https://cdn.dribbble.com/userupload/13994781/file/original-aa936ab9619914b7debecd452b772624.jpg?resize=1600x1200',
      title: 'Body and performance program',
      subtitle: '',
      duration: '10 minutes',
      pods: '2 pods',
    ),
    // Ajoutez d'autres exercices recommandés si nécessaire
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8.0), // Ajoutez du padding ici
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(urlProfilePhoto),
                radius: 20,
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
              // Action pour rechercher
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Action pour notifications
                },
              ),
              // Ajout du point rouge si nécessaire
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            //return const Center(child: CircularProgressIndicator());
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
                SliverToBoxAdapter(
                  child: AchievementBadgeWidget(
                    message: 'Vous avez 10,000 points',
                  ).redacted(
                    context: context,
                    redact: true,
                    configuration: RedactedConfiguration(
                      animationDuration:
                          const Duration(milliseconds: 800), //default
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200, // Ajustez cette valeur selon vos besoins
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return SessionCardWidget(
                          title: 'Ma séance $index',
                          duration: '15 minutes',
                          points: '64',
                          onStart: () {
                            // Action lorsque le bouton "C'est parti !" est appuyé
                          },
                        ).redacted(
                          context: context,
                          redact: true,
                          configuration: RedactedConfiguration(
                            animationDuration:
                                const Duration(milliseconds: 800), //default
                          ),
                        );
                      },
                      itemCount: 1,
                      itemWidth: 350.0,
                      layout: SwiperLayout.STACK,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: AppPallete.backgroundColorDarker,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Votre résumé hebdomadaire',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: dailyStats
                              .map((stat) => _buildSummaryCard(stat))
                              .toList(),
                        ),
                      ],
                    ),
                  ).redacted(
                    context: context,
                    redact: true,
                    configuration: RedactedConfiguration(
                      animationDuration:
                          const Duration(milliseconds: 800), //default
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: EmptySocialMediaPostWidget().redacted(
                          context: context,
                          redact: true,
                          configuration: RedactedConfiguration(
                            animationDuration:
                                const Duration(milliseconds: 800), //default
                          ),
                        ),
                      );
                    },
                    childCount: 5,
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
                      message: 'Vous avez 10,000 points',
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                  /* SliverToBoxAdapter(
                    child: Container(
                      //color: AppPallete.backgroundColorDarker,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Challenges',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height:
                                200, // Ajustez cette valeur selon vos besoins
                            child: Swiper(
                              itemBuilder: (BuildContext context, int index) {
                                return SessionCardWidget(
                                  title: 'Ma séance $index',
                                  duration: '15 minutes',
                                  points: '64',
                                  onStart: () {
                                    // Action lorsque le bouton "C'est parti !" est appuyé
                                  },
                                );
                              },
                              itemCount: 10,
                              itemWidth: 300.0,
                              itemHeight: 400.0,
                              layout: SwiperLayout.TINDER,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), */
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200, // Ajustez cette valeur selon vos besoins
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return SessionCardWidget(
                            title: 'Ma séance $index',
                            duration: '15 minutes',
                            points: '64',
                            onStart: () {
                              // Action lorsque le bouton "C'est parti !" est appuyé
                            },
                          );
                        },
                        itemCount: 10,
                        itemWidth: 350.0,
                        layout: SwiperLayout.STACK,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppPallete.backgroundColorDarker,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Votre résumé hebdomadaire',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: dailyStats
                                .map((stat) => _buildSummaryCard(stat))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /* SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SessionCardWidget(
                        imageUrl: 'https://your-image-url.com',
                        title: 'Ma séance',
                        duration: '15 minutes',
                        kcal: '293 kcal',
                        exercises: '3 exercices',
                        points: '64',
                        onStart: () {
                          // Action lorsque le bouton "C'est parti !" est appuyé
                        },
                      ),
                    ),
                  ), */
                  /* const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ), */
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: SocialMediaPostWidget(
                            post: state.posts[index],
                            onTap: () {
                              context.push('/home/details/$index',
                                  extra: state.posts[index]);
                            },
                          ),
                        );
                      },
                      childCount: state.posts.length,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is HomeError) {
            return _buildErrorScreen(context, state.message);
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildSummaryCard(DailyStats stats) {
    return Column(
      children: [
        Text(
          stats.label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          stats.value,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          stats.trend,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
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
              backgroundColor: AppPallete.primaryColor, // Couleur du bouton
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
