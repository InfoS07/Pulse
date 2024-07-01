import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';
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
        body: BlocListener<ProfilFollowBloc, ProfilFollowState>(
          listener: (context, state) {
            if (state is ProfilFollowSuccess || state is ProfilUnfollowSuccess) {
              // Refresh the page or do something when follow/unfollow is successful
              // For example, you can call setState() to refresh the widget
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProfilFollowPage(followers: followers, followings: followings),
                ),
              );
            }
          },
          child: TabBarView(
            children: [
              _buildFollowList(followers, followings, userId, context, isFollowersTab: true),
              _buildFollowList(followings, followings, userId, context, isFollowersTab: false),
            ],
          ),
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
            if (followStatus) {
              //followings.add(profile);
            } else {
              //followings.removeWhere((following) => following.username == profile.username);
            }
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
    );
  }
}
