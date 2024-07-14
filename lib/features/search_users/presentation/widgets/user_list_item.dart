import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/common/entities/user.dart';

class UserListItem extends StatelessWidget {
  final Profil profil;

  const UserListItem({required this.profil});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey,
        child: CachedNetworkImage(
          imageUrl: profil.profilePhoto,
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
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, size: 20),
        ),
      ),
      title: Text(profil.firstName + ' ' + profil.lastName),
      onTap: () {
        context.push('/otherProfil', extra: profil.uid);
      },
    );
  }
}
