part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadPosts extends HomeEvent {}

class LikePost extends HomeEvent {
  final int postId;

  LikePost(this.postId);

  @override
  List<Object> get props => [postId];
}

class DeletePost extends HomeEvent {
  final int postId;

  DeletePost(this.postId);

  @override
  List<Object> get props => [postId];
}

class AddCommentToPostEvent extends HomeEvent {
  final int trainingId;
  final String text;

  AddCommentToPostEvent(this.trainingId, this.text);

  @override
  List<Object> get props => [trainingId, text];
}

class ReportCommentEvent extends HomeEvent {
  final int commentId;
  final String reason;

  ReportCommentEvent(this.commentId, this.reason);

  @override
  List<Object> get props => [commentId, reason];
}
