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
