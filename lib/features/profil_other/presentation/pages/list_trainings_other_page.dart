import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/core/common/widgets/loader.dart';
import 'package:pulse/features/list_trainings/presentation/bloc/list_trainings_bloc.dart';
import 'package:pulse/features/list_trainings/presentation/pages/list_trainings_page.dart';

class TrainingListOtherScreen extends StatefulWidget {
  final String userId;

  const TrainingListOtherScreen({super.key, required this.userId});

  @override
  _TrainingListOtherScreenState createState() =>
      _TrainingListOtherScreenState();
}

class _TrainingListOtherScreenState extends State<TrainingListOtherScreen> {
  @override
  void initState() {
    super.initState();
    // Lancer l'événement pour obtenir les entraînements
    context
        .read<ListTrainingsBloc>()
        .add(ListTrainingsGetTraining(widget.userId));
  }

  Future<void> _refreshTrainings() async {
    // Lancer l'événement pour rafraîchir les entraînements
    context
        .read<ListTrainingsBloc>()
        .add(ListTrainingsGetTraining(widget.userId));
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
              child: Text('Aucun entrainement trouvé.',
                  style: TextStyle(color: Colors.white)),
            );
          }
        },
      ),
    );
  }
}
