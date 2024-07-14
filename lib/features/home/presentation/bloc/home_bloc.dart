// home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pulse/core/common/entities/add_comment.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/comments/domain/usecases/add_comment_uc.dart';
import 'package:pulse/features/comments/domain/usecases/report_comment_uc.dart';
import 'package:pulse/features/home/domain/usecases/delete_post_uc.dart';
import 'package:pulse/features/home/domain/usecases/get_posts_uc.dart';
import 'package:pulse/features/home/domain/usecases/like_post_uc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUC _getPosts;
  final LikePostUc _likePost;
  final AddCommentUc _addCommentUc;
  final DeletePostUc _deletePost;
  final ReportCommentUc _reportComment;

  HomeBloc(
      {required GetPostsUC getPosts,
      required LikePostUc likePost,
      required DeletePostUc deletePost,
      required AddCommentUc addCommentUc,
      required ReportCommentUc reportComment})
      : _getPosts = getPosts,
        _likePost = likePost,
        _deletePost = deletePost,
        _addCommentUc = addCommentUc,
        _reportComment = reportComment,
        super(HomeInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<LikePost>(_onLikePost);
    on<DeletePost>(_onDeletePost);
    on<AddCommentToPostEvent>(_onAddComment);
    on<ReportCommentEvent>(_onReportComment);
  }

  void _onLoadPosts(LoadPosts event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final res = await _getPosts(NoParams());

    res.fold(
      (l) => emit(HomeError(l.message)),
      (r) {
        if (r.isEmpty) {
          emit(HomeEmpty());
        } else {
          emit(HomeLoaded(r));
        }
      },
    );
  }

  void _onLikePost(LikePost event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final res = await _likePost(LikePostParams(event.postId));
      res.fold(
        (l) => emit(HomeError(l.toString())),
        (_) {
          if (currentState.posts.isEmpty)
            return;
          else {
            final updatedPosts = currentState.posts.map((post) {
              if (post!.id == event.postId) {
                return post.copyWith(
                    isLiked: !post.isLiked,
                    likes: !post.isLiked ? post.likes + 1 : post.likes - 1);
              }
              return post;
            }).toList();

            emit(HomeLoaded(updatedPosts));
          }
        },
      );
    }
  }

  void _onAddComment(
      AddCommentToPostEvent event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final res = await _addCommentUc(
          AddCommentParams(event.trainingId, AddComment(text: event.text)));
      res.fold(
        (l) => emit(HomeError(l.toString())),
        (r) {
          if (currentState.posts.isEmpty) return;

          final updatedPosts = currentState.posts.map((post) {
            if (post!.id == event.trainingId) {
              final updatedComments = List<Comment>.from(post.comments)..add(r);
              return post.copyWith(comments: updatedComments);
            }
            return post;
          }).toList();

          emit(HomeLoaded(updatedPosts));
        },
      );
    }
  }

  void _onDeletePost(
    DeletePost event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final res = await _deletePost(DeletePostParams(event.postId));
      res.fold(
        (l) => emit(HomeError(l.toString())),
        (_) {
          if (currentState.posts.isEmpty) return;
          final updatedPosts = currentState.posts
              .where((post) => post!.id != event.postId)
              .toList();
          emit(HomeLoaded(updatedPosts));
        },
      );
    }
  }

  void _onReportComment(
    ReportCommentEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _reportComment(ReportCommentParams(event.commentId, event.reason));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
