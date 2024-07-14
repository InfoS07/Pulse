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
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:pulse/features/profil_follow/presentation/widgets/follow_button_widget.dart';
import 'package:shimmer/shimmer.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? userId;
  List<Profil>? followers;
  List<Profil>? followings;

  @override
  void initState() {
    super.initState();
    // Lancer l'événement pour obtenir le profil
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
      context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
    }
    // Lancer l'événement pour obtenir les posts
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
  }

  Future<void> _refreshProfile() async {
    // Lancer l'événement pour rafraîchir le profil
    context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
    // Lancer l'événement pour rafraîchir les posts
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
  }

  void _signOut() {
    // Lancer l'événement pour se déconnecter
    context.read<AuthBloc>().add(AuthSignOut());
  }

  void _showSettingsDialog() {
    BottomSheetUtil.showCustomBottomSheet(
      context,
      onConfirm: () {
        /* BlocProvider.of<HomeBloc>(context).add(DeletePost(post!.id));
        context.go('/home');

        ToastService.showSuccessToast(
          context,
          length: ToastLength.long,
          expandedHeight: 100,
          message: "Entrainement supprimé",
        ); */
      },
      buttonText: 'Se déconnecter',
      buttonColor: Colors.red,
      confirmTextColor: Colors.white,
      cancelText: 'Annuler',
      cancelTextColor: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              //_showSettingsDialog();
              context.push('/profil/settings');
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfilBloc, ProfilState>(
        listener: (context, state) {
          if (state is ProfilFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfilLoading) {
            return const Loader();
          } else if (state is ProfilSuccess) {
            followings = state.followings;
            followers = state.followers;
            return RefreshIndicator(
              onRefresh: _refreshProfile,
              child: ListView(
                children: <Widget>[
                  _buildProfileHeader(state),
                  const SizedBox(height: 16.0),
                  _buildTrainingsList(),
                  /* const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.errorColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 14),
                      ),
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ), */
                ],
              ),
            );
          } else {
            return const Center(
                child:
                    Text('Profil Page', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfilSuccess state) {
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

  Widget _buildTrainingsList() {
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
          final userPosts =
              state.posts.where((post) => post!.user.uid == userId).toList();

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
                    print("index $index");
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80.0),
                Image(
                  image: AssetImage('assets/images/heart.png'),
                  width: 150,
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Historique d\'entrainement vide, lancez votre premier entrainement.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80.0),
                Image(
                  image: AssetImage('assets/images/heart.png'),
                  width: 150,
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Historique d\'entrainement vide, lancez votre premier entrainement.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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

  Widget _buildListTile(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      trailing: Icon(
        icon,
        color: Colors.white,
      ),
      onTap: () {
        if (title == "Entrainements") {
          context.push('/profil/entrainements');
        }
        // Ajouter l'action de navigation
      },
    );
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
              imageUrl: post.exercice.photos.firstWhere(
                  (element) => !element.endsWith('.mp4'),
                  orElse: () => post.exercice.photos.first),
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
