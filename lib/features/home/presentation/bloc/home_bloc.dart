// home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/home/domain/usecases/get_posts_uc.dart';
//import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUC _getPosts;

  HomeBloc({required GetPostsUC getPosts})
      : _getPosts = getPosts,
        super(HomeInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<FilterPosts>(_onFilterPosts);
  }

  void _onLoadPosts(LoadPosts event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    // Simulate fetching posts from a data source
    /* final List<SocialMediaPost> allPosts = List.generate(
      10,
      (index) => SocialMediaPost(
        profileImageUrl:
            'https://media.licdn.com/dms/image/C5603AQGS7eAEozhDzw/profile-displayphoto-shrink_200_200/0/1562875334307?e=2147483647&v=beta&t=Pp3nnMsNgTceqPRuxDHG1NU-3wEA_hQR3lL5ru1Ghvw',
        username: 'Moi $index',
        timestamp: '12/01/2024 - 12:${45 + index}',
        title: 'Course à pied',
        content:
            'Je viens de faire la meilleure séance de ma vie, incroyable je recommande cet exo :)',
        postImageUrl:
            'https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=600',
        likes: 20 + index,
        comments: 4 + index,
      ),
    ); */

    emit(HomeLoading());
    final res = await _getPosts(NoParams());

    res.fold(
      (l) => emit(HomeError(l.message)),
      (r) => emit(HomeLoaded(r, 'Tout')),
    );
  }

  void _onFilterPosts(FilterPosts event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredPosts = _getFilteredPosts(event.filter, currentState.posts);

      emit(HomeLoaded(filteredPosts, event.filter));
    }
  }

  List<SocialMediaPost> _getFilteredPosts(
      String filter, List<SocialMediaPost> allPosts) {
    switch (filter) {
      case 'Moi':
        return allPosts;
      case 'Abonné':
        return allPosts;
      case 'Tout':
        return allPosts;
      default:
        return allPosts;
    }
  }
}
