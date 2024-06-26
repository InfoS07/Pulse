import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pulse/features/profil/presentation/bloc/profil_bloc.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    // Lancer l'événement pour obtenir le profil
    context.read<ProfilBloc>().add(ProfilGetProfil());
  }

  Future<void> _refreshProfile() async {
    // Lancer l'événement pour rafraîchir le profil
    context.read<ProfilBloc>().add(ProfilGetProfil());
  }

  void _signOut() {
    // Lancer l'événement pour se déconnecter
    context.read<AuthBloc>().add(AuthSignOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.black,
      ),
      body: BlocConsumer<ProfilBloc, ProfilState>(
        listener: (context, state) {
          // Écouter les états pour afficher des messages, rediriger, etc.
          if (state is ProfilFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfilLoading) {
            return const Loader();
          } else if (state is ProfilSuccess) {
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
                          backgroundImage:
                              NetworkImage(state.profil.profilePhoto),
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
                            _buildInfoColumn('123', 'Activités'),
                            _buildInfoColumn('12', 'Abonnés'),
                            _buildInfoColumn('230', 'Abonnements'),
                          ],
                        ),
                        const Divider(color: Colors.grey, height: 32),
                        _buildListTile('Activités', Icons.arrow_forward_ios),
                        _buildListTile('Statistiques', Icons.arrow_forward_ios),
                        _buildListTile('Pods', Icons.arrow_forward_ios),
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
                        const SizedBox(height: 16.0),
                        Center(
                          child: TextButton(
                            onPressed: _signOut,
                            child: Text(
                              'Se déconnecter',
                              style: TextStyle(color: Colors.red),
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
                child:
                    Text('Profil Page', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return GestureDetector(
      onTap: () {
        // Ajouter l'action de navigation
        context.push('/profil/follow');
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
        // Ajouter l'action de navigation
      },
    );
  }
}
