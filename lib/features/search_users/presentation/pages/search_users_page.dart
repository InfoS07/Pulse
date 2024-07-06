import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/features/search_users/presentation/bloc/search_users_bloc.dart';
import 'package:pulse/features/search_users/presentation/widgets/user_list_item.dart';
import 'package:pulse/init_dependencies.dart';

class SearchUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SearchUsersView(),
    );
  }
}

class SearchUsersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher des gens qui pulse',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                context
                    .read<SearchUsersBloc>()
                    .add(SearchUsersQueryChanged(query: query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchUsersBloc, SearchUsersState>(
              builder: (context, state) {
                if (state is SearchUsersLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is SearchUsersLoaded) {
                  if (state.profils.isEmpty) {
                    return Center(child: Text('Aucun utilisateur trouvé'));
                  } else {
                    return ListView.builder(
                      itemCount: state.profils.length,
                      itemBuilder: (context, index) {
                        final profil = state.profils[index];
                        return profil != null
                            ? UserListItem(profil: profil)
                            : Container();
                      },
                    );
                  }
                } else if (state is SearchUsersError) {
                  return Center(child: Text(state.message));
                } else {
                  return Center(child: Text('Vous êtes seul :('));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
