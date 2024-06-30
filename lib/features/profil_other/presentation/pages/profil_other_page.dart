import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/features/profil_other/presentation/bloc/profil_other_bloc.dart';

class ProfilOtherPage extends StatefulWidget {
  @override
  _ProfilOtherPageState createState() => _ProfilOtherPageState();
}

class _ProfilOtherPageState extends State<ProfilOtherPage> {
  @override
  void initState() {
    super.initState();
    // Lancer l'événement pour obtenir le profil
    context.read<OtherProfilBloc>().add(OtherProfilGetProfil());
  }

  Future<void> _refreshProfile() async {
    // Lancer l'événement pour rafraîchir le profil
    context.read<OtherProfilBloc>().add(OtherProfilGetProfil());
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
      body: BlocConsumer<OtherProfilBloc, OtherProfilState>(
        listener: (context, state) {
          // Écouter les états pour afficher des messages, rediriger, etc.
          if (state is OtherProfilFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is OtherProfilLoading) {
            return const Loader();
          } else if (state is OtherProfilSuccess) {
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
                            _buildInfoColumn('23', 'Abonnés'),
                            _buildInfoColumn('666', 'Abonnements'),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Action pour suivre
                          },
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text('Suivre',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            side: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        const Divider(color: Colors.grey, height: 32),
                        _buildListTile('Activités', Icons.arrow_forward_ios),
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
        context.push('/otherProfil/followOther');
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
