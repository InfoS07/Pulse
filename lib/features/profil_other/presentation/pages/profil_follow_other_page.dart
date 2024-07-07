import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:pulse/features/profil_other/presentation/bloc/profil_other_bloc.dart';

class OtherProfilFollowPage extends StatefulWidget {
  final String userIdOther; // Nouveau paramètre userIdOther

  const OtherProfilFollowPage({
    super.key,
    required this.userIdOther,
  });

  @override
  _OtherProfilFollowPageState createState() => _OtherProfilFollowPageState();
}

class _OtherProfilFollowPageState extends State<OtherProfilFollowPage> {
  String? userId;
  List<Profil> userFollowers = [];
  List<Profil> userFollowings = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
      context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
    }
    context
        .read<OtherProfilBloc>()
        .add(OtherProfilGetProfil(widget.userIdOther));
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
        body: MultiBlocListener(
          listeners: [
            BlocListener<ProfilBloc, ProfilState>(
              listener: (context, state) {
                if (state is ProfilSuccess) {
                  setState(() {
                    userFollowers = state.followers;
                    userFollowings = state.followings;
                  });
                }
              },
            ),
            BlocListener<OtherProfilBloc, OtherProfilState>(
              listener: (context, state) {
                if (state is OtherProfilSuccess) {
                  // Réagir à la mise à jour réussie du profil
                }
              },
            ),
            BlocListener<ProfilFollowBloc, ProfilFollowState>(
              listener: (context, followState) {
                if (followState is ProfilFollowSuccess ||
                    followState is ProfilUnfollowSuccess) {
                  // Rafraîchir le profil après une opération de follow/unfollow réussie
                  context
                      .read<OtherProfilBloc>()
                      .add(OtherProfilGetProfil(widget.userIdOther));
                  context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
                }
              },
            ),
          ],
          child: BlocBuilder<OtherProfilBloc, OtherProfilState>(
            builder: (context, profilState) {
              if (profilState is OtherProfilSuccess) {
                final followers = profilState.followers;
                final followings = profilState.followings;

                return TabBarView(
                  children: [
                    _buildFollowList(followers, userFollowings, userId, context,
                        isFollowersTab: true),
                    _buildFollowList(
                        followings, userFollowings, userId, context,
                        isFollowersTab: false),
                  ],
                );
              } else if (profilState is ProfilLoading) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return const Center(
                    child: Text('Erreur de chargement du profil'));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFollowList(List<Profil> profiles, List<Profil> userFollowings,
      String? userId, BuildContext context,
      {required bool isFollowersTab}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        bool isFollowing = userFollowings
            .any((following) => following.username == profile.username);

        return OtherFollowItem(
          profile: profile,
          isFollowing: isFollowing,
          userId: userId,
          onFollowChanged: (followStatus) {
            setState(() {
              context
                  .read<OtherProfilBloc>()
                  .add(OtherProfilGetProfil(widget.userIdOther));
              context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
            });
          },
        );
      },
    );
  }
}

class OtherFollowItem extends StatefulWidget {
  final Profil profile;
  final bool isFollowing;
  final String? userId;
  final ValueChanged<bool> onFollowChanged;

  const OtherFollowItem({
    super.key,
    required this.profile,
    required this.isFollowing,
    required this.userId,
    required this.onFollowChanged,
  });

  @override
  _OtherFollowItemState createState() => _OtherFollowItemState();
}

class _OtherFollowItemState extends State<OtherFollowItem> {
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
          context.push('/otherProfil', extra: widget.profile.uid);
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
                          ProfilFollow(FollowParams(
                              userId: widget.userId!,
                              followerId: widget.profile.uid)),
                        );
                  } else {
                    context.read<ProfilFollowBloc>().add(
                          ProfilUnfollow(UnfollowParams(
                              userId: widget.userId!,
                              followerId: widget.profile.uid)),
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
                side: BorderSide(
                    color: isFollowing ? Colors.grey : Colors.greenAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
