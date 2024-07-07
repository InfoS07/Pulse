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
        backgroundImage: NetworkImage(profil.profilePhoto),
      ),
      title: Text(profil.firstName + ' ' + profil.lastName),
      onTap: () {
        context.push('/otherProfil', extra: profil.uid);
      },
    );
  }
}
