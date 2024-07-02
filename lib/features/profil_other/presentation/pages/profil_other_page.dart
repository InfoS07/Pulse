import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:pulse/features/profil_follow/domain/usecases/follow.dart';
import 'package:pulse/features/profil_follow/domain/usecases/unfollow.dart';
import 'package:pulse/features/profil_follow/presentation/bloc/profil_follow_bloc.dart';
import 'package:pulse/features/profil_other/presentation/bloc/profil_other_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';

class ProfilOtherPage extends StatefulWidget {
  final String userId;

  ProfilOtherPage({required this.userId});

  @override
  _ProfilOtherPageState createState() => _ProfilOtherPageState();
}

class _ProfilOtherPageState extends State<ProfilOtherPage> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      currentUserId = authState.user.id.toString();
    }
    // Lancer l'événement pour obtenir le profil
    context.read<OtherProfilBloc>().add(OtherProfilGetProfil(widget.userId));
  }

  Future<void> _refreshProfile() async {
    // Lancer l'événement pour rafraîchir le profil
    context.read<OtherProfilBloc>().add(OtherProfilGetProfil(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OtherProfilBloc, OtherProfilState>(
            listener: (context, state) {
              if (state is OtherProfilFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<ProfilFollowBloc, ProfilFollowState>(
            listener: (context, followState) {
              if (followState is ProfilFollowSuccess || followState is ProfilUnfollowSuccess) {
                // Rafraîchir le profil après une opération de follow/unfollow réussie
                _refreshProfile();
              }
            },
          ),
        ],
        child: BlocBuilder<OtherProfilBloc, OtherProfilState>(
          builder: (context, state) {
            if (state is OtherProfilLoading) {
              return const Loader();
            } else if (state is OtherProfilSuccess) {
              bool isFollowing = state.followers.any((follower) => follower.id.toString() == currentUserId);
              return RefreshIndicator(
                onRefresh: _refreshProfile,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(state.profil.profilePhoto),
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            '${state.profil.firstName} ${state.profil.lastName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            state.profil.username,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoColumn(state.followers.length.toString(), 'Abonnés'),
                              _buildInfoColumn(state.followings.length.toString(), 'Abonnements'),
                              _buildInfoColumn(state.trainings.length.toString(), 'Entrainements'),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (isFollowing) {
                                context.read<ProfilFollowBloc>().add(
                                  ProfilUnfollow(UnfollowParams(userId: currentUserId!, followerId: widget.userId)),
                                );
                              } else {
                                context.read<ProfilFollowBloc>().add(
                                  ProfilFollow(FollowParams(userId: currentUserId!, followerId: widget.userId)),
                                );
                              }
                            },
                            icon: Icon(isFollowing ? Icons.check : Icons.add, color: Colors.white),
                            label: Text(isFollowing ? 'Suivi' : 'Suivre', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.grey : Colors.greenAccent,
                              side: BorderSide(color: isFollowing ? Colors.grey : Colors.greenAccent),
                            ),
                          ),
                          const Divider(color: Colors.grey, height: 32),
                          _buildListTile('Entrainements', Icons.arrow_forward_ios),
                          _buildListTile('Statistiques', Icons.arrow_forward_ios),
                          const Divider(color: Colors.grey, height: 32),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Collection de trophées',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Profil Page', style: TextStyle(color: Colors.white)),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return GestureDetector(
      onTap: () {
        if(label != "Entrainements"){
          context.push('/otherProfil/followOther');
        }
      },
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      trailing: Icon(
        icon,
        color: Colors.white,
      ),
      onTap: () {
        if(title == "Entrainements"){
          context.push('/otherProfil/entrainementsOther',extra: widget.userId);
        }
        // Ajouter l'action de navigation
      },
    );
  }
}
