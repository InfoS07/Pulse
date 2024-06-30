import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';


class ProfilFollowPage extends StatelessWidget {
  final List<Profil> followers;
  final List<Profil> followings;

  ProfilFollowPage({required this.followers, required this.followings});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AppUserCubit>().state;
    String? userId;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.id.toString();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Abonnés'),
              Tab(text: 'Abonnement'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFollowList(followers, userId, context),
            _buildFollowList(followings, userId, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowList(List<Profil> profiles, String? userId, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];

        // Vérifier si le profil est suivi
        bool isFollowing = followers.any((follower) => follower.username == profile.username);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profile.profilePhoto),
                radius: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  profile.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BlocBuilder<ProfilFollowBloc, ProfilFollowState>(
                builder: (context, state) {
                  if (state is ProfilFollowSuccess) {
                    isFollowing = !isFollowing; // Update follow status based on state
                  }

                  return ElevatedButton.icon(
                    onPressed: () {
                      // Déclencher l'événement ProfilFollow
                      if(!isFollowing){
                        context.read<ProfilFollowBloc>().add(
                          ProfilFollow(FollowParams(userId: userId!, followerId: profile.id.toString())),
                        );
                      }
                    },
                    icon: Icon(
                      isFollowing ? Icons.check : Icons.add,
                      color: Colors.white,
                    ),
                    label: Text(
                      isFollowing ? 'Suivi' : 'Suivre',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey : Colors.greenAccent,
                      side: BorderSide(color: isFollowing ? Colors.grey : Colors.greenAccent),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
