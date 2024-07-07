import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';

class TrainingListScreen extends StatefulWidget {
  @override
  _TrainingListScreenState createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    // Obtenir l'ID de l'utilisateur actuel
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
    }
    // Lancer l'événement pour obtenir les posts
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
  }

  Future<void> _refreshPosts() async {
    // Lancer l'événement pour rafraîchir les posts
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tout vos entrainements'),
        backgroundColor: Colors.black,
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // Écouter les états pour afficher des messages, rediriger, etc.
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
            // Filtrer les posts par l'ID de l'auteur
            print(userId.toString());
            //print(state.posts);
            final userPosts = state.posts.where((post) => post.uid == userId).toList();

            return RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return PostListItem(
                    post: post,
                    onTap: () {
                      context.go('/profil/entrainements/details/$index', extra: post);
                    },
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text('Aucun post trouvé.', style: TextStyle(color: Colors.white)),
            );
          }
        },
      ),
    );
  }
}

class PostListItem extends StatelessWidget {
  final SocialMediaPost post;
  final VoidCallback onTap;

  const PostListItem({Key? key, required this.post, required this.onTap}) : super(key: key);

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
          leading: post.postImageUrl != null && post.postImageUrl.isNotEmpty
              ? Image.network(
                  post.postImageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : null,
          title: Text(
            post.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${post.timestamp}\n$descriptionPreview',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

class TrainingListItem extends StatelessWidget {
  final TrainingList training;

  const TrainingListItem({Key? key, required this.training}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String descriptionPreview = training.description;
    if (training.description.length > 20) {
      descriptionPreview = '${training.description.substring(0, 20)}...';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Image.network(
          'https://img.freepik.com/photos-gratuite/design-colore-design-spirale_188544-9588.jpg',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          training.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${training.date}\n$descriptionPreview',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
      ),
    );
  }
}
