import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                        Text(
                          'Email: ${state.profil.email}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Date de naissance: ${state.profil.birthDate.toLocal()}'
                              .split(' ')[0],
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Taille: ${state.profil.heightCm} cm',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Poids: ${state.profil.weightKg} kg',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Profil Page'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _signOut,
        child: const Icon(Icons.logout),
        tooltip: 'Se déconnecter',
      ),
    );
  }
}
