import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/bottom_sheet_util.dart';
import 'package:pulse/core/utils/formatters.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';
import 'package:pulse/features/profil_follow/presentation/widgets/follow_button_widget.dart';
import 'package:pulse/features/profil_other/presentation/bloc/profil_other_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ProfilOtherPage extends StatefulWidget {
  final String userId;

  const ProfilOtherPage({super.key, required this.userId});

  @override
  _ProfilOtherPageState createState() => _ProfilOtherPageState();
}

class _ProfilOtherPageState extends State<ProfilOtherPage> {
  String? currentUserId;
  List<Profil>? followers;
  List<Profil>? followings;
  final ValueNotifier<bool> _refreshNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      currentUserId = authState.user.uid;
    }
    // Lancer l'événement pour obtenir le profil
    context.read<OtherProfilBloc>().add(OtherProfilGetProfil(widget.userId));
    // Lancer l'événement pour obtenir les posts
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
  }

  Future<void> _refreshProfile() async {
    // Lancer l'événement pour rafraîchir le profil
    context.read<OtherProfilBloc>().add(OtherProfilGetProfil(widget.userId));
    // Lancer l'événement pour rafraîchir les posts
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
    // Notifier le ValueNotifier pour forcer la reconstruction
    _refreshNotifier.value = !_refreshNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _refreshNotifier,
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Compte'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<OtherProfilBloc, OtherProfilState>(
                listener: (context, state) {
                  if (state is OtherProfilFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
              ),
              BlocListener<ProfilFollowBloc, ProfilFollowState>(
                listener: (context, followState) {
                  if (followState is ProfilFollowFailure ||
                      followState is ProfilFollowFailure) {
                    // Rafraîchir le profil après une opération de follow/unfollow réussie
                    _refreshProfile();
                  }
                },
              ),
            ],
            child: BlocBuilder<OtherProfilBloc, OtherProfilState>(
              builder: (context, state) {
                if (state is OtherProfilLoading) {
                  return const Loader();
                } else if (state is OtherProfilSuccess) {
                  followers = state.followers;
                  followings = state.followings;
                  bool isFollowing = state.followers
                      .any((follower) => follower.uid == currentUserId);
                  return RefreshIndicator(
                    onRefresh: _refreshProfile,
                    child: ListView(
                      children: <Widget>[
                        _buildProfileHeader(state, isFollowing),
                        const SizedBox(height: 16.0),
                        _buildTrainingsList(state.profil),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('Profil Page',
                        style: TextStyle(color: Colors.white)),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(OtherProfilSuccess state, bool isFollowing) {
    return Container(
      color: AppPallete.backgroundColorDarker,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                child: CachedNetworkImage(
                  imageUrl: state.profil.profilePhoto,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 80.0,
                    height: 80.0,
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
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.profil.firstName} ${state.profil.lastName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    state.profil.username,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildInfoColumn(followers!.length.toString(), 'Abonnés'),
                  const SizedBox(width: 25.0),
                  _buildInfoColumn(
                      followings!.length.toString(), 'Abonnements'),
                ],
              ),
              FollowButton(
                isFollowing: isFollowing,
                userId: currentUserId!,
                profileId: widget.userId,
                onFollowChanged: (isFollowing) {
                  if (isFollowing) {
                    context.read<ProfilFollowBloc>().add(
                          ProfilUnfollow(UnfollowParams(
                              userId: currentUserId!,
                              followerId: widget.userId)),
                        );
                  } else {
                    context.read<ProfilFollowBloc>().add(
                          ProfilFollow(FollowParams(
                              userId: currentUserId!,
                              followerId: widget.userId)),
                        );
                  }
                },
              ),
              /*  ElevatedButton.icon(
                onPressed: () {
                  if (isFollowing) {
                    context.read<ProfilFollowBloc>().add(
                          ProfilUnfollow(UnfollowParams(
                              userId: currentUserId!,
                              followerId: widget.userId)),
                        );
                  } else {
                    context.read<ProfilFollowBloc>().add(
                          ProfilFollow(FollowParams(
                              userId: currentUserId!,
                              followerId: widget.userId)),
                        );
                  }
                },
                icon: Icon(isFollowing ? Icons.check : Icons.add,
                    color: Colors.white),
                label: Text(isFollowing ? 'Suivi' : 'Suivre',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFollowing ? Colors.grey : Colors.greenAccent,
                  side: BorderSide(
                      color: isFollowing ? Colors.grey : Colors.greenAccent),
                ),
              ), */
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return GestureDetector(
      onTap: () {
        // Ajouter l'action de navigation
        context.push('/profil/follow');
      },
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingsList(Profil profil) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Loader();
        } else if (state is HomeLoaded) {
          final userPosts = state.posts
              .where((post) => post!.userUid == widget.userId)
              .toList();

          if (userPosts.isEmpty) {
            return const Center(
              child: Text('Aucun entraînement trouvé.',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final groupedPosts =
              _groupPostsByWeek(userPosts as List<SocialMediaPost>);

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groupedPosts.length,
            itemBuilder: (context, index) {
              final weekPosts = groupedPosts.entries.elementAt(index);
              final weekRange = _getWeekDateRange(weekPosts.key);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      weekRange,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ...weekPosts.value.map((post) {
                    return PostListItem(
                      post: post,
                      onTap: () {
                        context.push('/home/details/$index', extra: post);
                      },
                    );
                  }),
                ],
              );
            },
          );
        } else if (state is HomeEmpty) {
          return const SizedBox();
        } else {
          return const Center(
            child: Text('Erreur de chargement des entraînements.',
                style: TextStyle(color: Colors.white)),
          );
        }
      },
    );
  }

  Map<int, List<SocialMediaPost>> _groupPostsByWeek(
      List<SocialMediaPost> posts) {
    final Map<int, List<SocialMediaPost>> groupedPosts = {};
    for (var post in posts) {
      final stringToTimestamp = DateFormat('yyyy-MM-dd').parse(post.timestamp);
      final weekOfYear = weekNumber(stringToTimestamp);
      if (groupedPosts.containsKey(weekOfYear)) {
        groupedPosts[weekOfYear]!.add(post);
      } else {
        groupedPosts[weekOfYear] = [post];
      }
    }
    return groupedPosts;
  }

  int weekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  String _getWeekDateRange(int weekNumber) {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final startOfWeek =
        firstDayOfYear.add(Duration(days: (weekNumber - 1) * 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final dateFormat = DateFormat('d MMMM', 'fr_FR');
    return '${dateFormat.format(startOfWeek)} au ${dateFormat.format(endOfWeek)}';
  }
}

class PostListItem extends StatelessWidget {
  final SocialMediaPost post;
  final VoidCallback onTap;

  const PostListItem({Key? key, required this.post, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String descriptionPreview = post.description;
    if (post.description.length > 20) {
      descriptionPreview = '${post.description.substring(0, 20)}...';
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            child: CachedNetworkImage(
              imageUrl: post.exercice.photos.first,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                enabled: true,
                child: Container(
                  color: Colors.grey[200],
                  height: 50,
                  width: 50,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                height: 50,
                width: 50,
                child:
                    const Center(child: Icon(Icons.error, color: Colors.white)),
              ),
            ),
          ),
          title: Text(
            post.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            formatTimestamp(post.timestamp),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
