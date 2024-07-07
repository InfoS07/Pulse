import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/features/challenges_users/domain/usecases/get_challenges_users.dart';
import 'package:pulse/features/challenges_users/presentation/bloc/challenges_users_bloc.dart';

class ChallengeUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Challenge Users')),
      body: ChallengeUserView(),
    );
  }
}

class ChallengeUserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengesUsersBloc, ChallengesUsersState>(
      builder: (context, state) {
        if (state is ChallengesUsersLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ChallengesUsersSuccess) {
          return ListView.builder(
            itemCount: state.challenges.length,
            itemBuilder: (context, index) {
              final challengeUser = state.challenges[index];
              int totalScore = challengeUser!.participants.values.fold(0, (prev, element) => prev + (element['score'] as int));
              return ListTile(
                title: Text(challengeUser.name),
                subtitle: Text('Score: $totalScore'),
              );
            },
          );
        } else if (state is ChallengesUsersError) {
          return Center(child: Text('Failed to fetch challenge users'));
        }
        return Center(child: Text('No challenge users'));
      },
    );
  }
}