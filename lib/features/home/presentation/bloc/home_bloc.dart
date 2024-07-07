// home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/home/domain/usecases/delete_post_uc.dart';
import 'package:pulse/features/home/domain/usecases/get_posts_uc.dart';
import 'package:pulse/features/home/domain/usecases/like_post_uc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUC _getPosts;
  final LikePostUc _likePost;
  final DeletePostUc _deletePost;

  HomeBloc(
      {required GetPostsUC getPosts,
      required LikePostUc likePost,
      required DeletePostUc deletePost})
      : _getPosts = getPosts,
        _likePost = likePost,
        _deletePost = deletePost,
        super(HomeInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<LikePost>(_onLikePost);
    on<DeletePost>(_onDeletePost);
  }

  void _onLoadPosts(LoadPosts event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final res = await _getPosts(NoParams());

    res.fold(
      (l) => emit(HomeError(l.message)),
      (r) => emit(HomeLoaded(r)),
    );
  }

  void _onLikePost(LikePost event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final res = await _likePost(LikePostParams(event.postId));
      res.fold(
        (l) => emit(HomeError(l.toString())),
        (_) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(
                  isLiked: !post.isLiked,
                  likes: !post.isLiked ? post.likes + 1 : post.likes - 1);
            }
            return post;
          }).toList();

          emit(HomeLoaded(updatedPosts));
        },
      );
    }
  }

  void _onDeletePost(DeletePost event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final res = await _deletePost(DeletePostParams(event.postId));
      res.fold(
        (l) => emit(HomeError(l.toString())),
        (_) {
          final updatedPosts = currentState.posts
              .where((post) => post.id != event.postId)
              .toList();
          emit(HomeLoaded(updatedPosts));
        },
      );
    }
  }
}
