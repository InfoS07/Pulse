import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/trainingList.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/features/list_trainings/presentation/bloc/list_trainings_bloc.dart';

class TrainingListScreen extends StatefulWidget {
  @override
  _TrainingListScreenState createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    // Lancer l'événement pour obtenir les entraînements
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.id.toString();
      context.read<ListTrainingsBloc>().add(ListTrainingsGetTraining(userId!));
    }
  }

  Future<void> _refreshTrainings() async {
    // Lancer l'événement pour rafraîchir les entraînements
    context.read<ListTrainingsBloc>().add(ListTrainingsGetTraining(userId!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tout vos entrainements'),
        backgroundColor: Colors.black,
      ),
      body: BlocConsumer<ListTrainingsBloc, ListTtrainingsState>(
        listener: (context, state) {
          // Écouter les états pour afficher des messages, rediriger, etc.
          if (state is ListTrainingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ListTrainingsLoading) {
            return const Loader();
          } else if (state is ListTrainingsSuccess) {
            return RefreshIndicator(
              onRefresh: _refreshTrainings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.trainings.length,
                itemBuilder: (context, index) {
                  final training = state.trainings[index];
                  return TrainingListItem(training: training);
                },
              ),
            );
          } else {
            return const Center(
              child: Text('Aucun entrainement trouvé.', style: TextStyle(color: Colors.white)),
            );
          }
        },
      ),
    );
  }
}

class TrainingListItem extends StatelessWidget {
  final TrainingList training;

  const TrainingListItem({Key? key, required this.training}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String descriptionPreview = training.description;
    if (training.description.length > 20) {
      descriptionPreview = '${training.description.substring(0, 20)}...';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Image.network(
          'https://img.freepik.com/photos-gratuite/design-colore-design-spirale_188544-9588.jpg',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          training.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${training.date}\n$descriptionPreview',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
      ),
    );
  }
}

