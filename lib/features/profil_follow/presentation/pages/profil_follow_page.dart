import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:pulse/features/profil_follow/presentation/widgets/follow_button_widget.dart';

class ProfilFollowPage extends StatefulWidget {
  const ProfilFollowPage({super.key});

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
      userId = authState.user.uid;
      context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connexions'),
          scrolledUnderElevation: 0,
          backgroundColor: AppPallete.backgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: const TabBar(
            indicatorColor: AppPallete.primaryColor,
            indicatorWeight: 3.0,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
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
                  if (followState is ProfilFollowSuccess ||
                      followState is ProfilUnfollowSuccess) {
                    context.read<ProfilBloc>().add(ProfilGetProfil(userId!));
                  }
                },
                child: TabBarView(
                  children: [
                    _buildFollowList(followers, followings, userId, context,
                        isFollowersTab: true),
                    _buildFollowList(followings, followings, userId, context,
                        isFollowersTab: false),
                  ],
                ),
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
    );
  }

  Widget _buildFollowList(List<Profil> profiles, List<Profil> followings,
      String? userId, BuildContext context,
      {required bool isFollowersTab}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        bool isFollowing = followings
            .any((following) => following.username == profile.username);

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

  const FollowItem({
    super.key,
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
          context.push('/otherProfil', extra: widget.profile.uid);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              child: CachedNetworkImage(
                imageUrl: widget.profile.profilePhoto,
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
                    const Icon(Icons.person, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.profile.username,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            FollowButton(
              userId: widget.userId ?? '',
              profileId: widget.profile.uid,
              isFollowing: isFollowing,
              onFollowChanged: (followStatus) {
                setState(() {
                  isFollowing = followStatus;
                  widget.onFollowChanged(followStatus);
                });
              },
            ),
            /* ElevatedButton.icon(
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
            ), */
          ],
        ),
      ),
    );
  }
}
