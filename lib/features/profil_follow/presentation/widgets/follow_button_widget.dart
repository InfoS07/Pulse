import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';

class FollowButton extends StatefulWidget {
  final String userId;
  final String profileId;
  final bool isFollowing;
  final Function(bool) onFollowChanged;

  FollowButton({
    required this.userId,
    required this.profileId,
    required this.isFollowing,
    required this.onFollowChanged,
  });

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool isFollowing;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        if (widget.userId != null) {
          if (!isFollowing) {
            context.read<ProfilFollowBloc>().add(
                  ProfilFollow(FollowParams(
                      userId: widget.userId, followerId: widget.profileId)),
                );
          } else {
            context.read<ProfilFollowBloc>().add(
                  ProfilUnfollow(UnfollowParams(
                      userId: widget.userId, followerId: widget.profileId)),
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
        color: isFollowing ? Colors.grey : AppPallete.primaryColor,
      ),
      label: Text(
        isFollowing ? 'Suivi' : 'Suivre',
        style: TextStyle(
          color: isFollowing ? Colors.grey : AppPallete.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: isFollowing ? Colors.grey : AppPallete.primaryColor,
        side: BorderSide(
            color: isFollowing ? Colors.grey : AppPallete.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
}
