part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class ReportCommentEvent extends CommentEvent {
  final int commentIndex;
  final String reportReason;

  const ReportCommentEvent(this.commentIndex, this.reportReason);

  @override
  List<Object> get props => [commentIndex, reportReason];
}
