import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';

class ProfilFollowPage extends StatefulWidget {
  @override
  _ProfilFollowPageState createState() => _ProfilFollowPageState();
}

class _ProfilFollowPageState extends State<ProfilFollowPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.id.toString();
      context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: BlocConsumer<ProfilBloc, ProfilState>(
          listener: (context, state) {
            if (state is ProfilSuccess) {
              // Réagir à la mise à jour réussie du profil
            }
          },
          builder: (context, profilState) {
            if (profilState is ProfilSuccess) {
              final followers = profilState.followers;
              final followings = profilState.followings;

              return BlocListener<ProfilFollowBloc, ProfilFollowState>(
                listener: (context, followState) {
                  if (followState is ProfilFollowSuccess || followState is ProfilUnfollowSuccess) {
                    // Rafraîchir le profil après une opération de follow/unfollow réussie
                    context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
                  }
                },
                child: TabBarView(
                  children: [
                    _buildFollowList(followers, followings, userId, context, isFollowersTab: true),
                    _buildFollowList(followings, followings, userId, context, isFollowersTab: false),
                  ],
                ),
              );
            } else if (profilState is ProfilLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('Erreur de chargement du profil'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildFollowList(List<Profil> profiles, List<Profil> followings, String? userId, BuildContext context, {required bool isFollowersTab}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        bool isFollowing = followings.any((following) => following.username == profile.username);

        return FollowItem(
          profile: profile,
          isFollowing: isFollowing,
          userId: userId,
          onFollowChanged: (followStatus) {
            // Optionally handle the follow status change
            setState(() {
              context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
            });
          },
        );
      },
    );
  }
}

class FollowItem extends StatefulWidget {
  final Profil profile;
  final bool isFollowing;
  final String? userId;
  final ValueChanged<bool> onFollowChanged;

  FollowItem({
    required this.profile,
    required this.isFollowing,
    required this.userId,
    required this.onFollowChanged,
  });

  @override
  _FollowItemState createState() => _FollowItemState();
}

class _FollowItemState extends State<FollowItem> {
  late bool isFollowing;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          // Ajouter l'action de navigation
          context.push('/otherProfil',extra: widget.profile.id.toString());
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profile.profilePhoto),
              radius: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.profile.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.userId != null) {
                  if (!isFollowing) {
                    context.read<ProfilFollowBloc>().add(
                      ProfilFollow(FollowParams(userId: widget.userId!, followerId: widget.profile.id.toString())),
                    );
                  } else {
                    context.read<ProfilFollowBloc>().add(
                      ProfilUnfollow(UnfollowParams(userId: widget.userId!, followerId: widget.profile.id.toString())),
                    );
                  }
                  setState(() {
                    isFollowing = !isFollowing;
                    widget.onFollowChanged(isFollowing);
                  });
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
            ),
          ],
        ),
      ),
    );
  }
}
