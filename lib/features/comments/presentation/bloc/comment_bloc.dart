import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pulse/core/common/entities/add_comment.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/comments/domain/usecases/add_comment_uc.dart';
import 'package:pulse/features/comments/domain/usecases/get_comments_uc.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc() : super(CommentInitial()) {
    /* on<ReportCommentEvent>((event, emit) async {
      emit(CommentLoading());
      try {
        // Simulate reporting a comment to the server
        await Future.delayed(Duration(seconds: 1));
        // Remove the comment from the list
        final currentState = state;
        if (currentState is CommentLoaded) {
          final updatedComments =
              List<Map<String, String>>.from(currentState.comments)
                ..removeAt(event.commentIndex);
          emit(CommentLoaded(updatedComments));
        }
      } catch (e) {
        emit(CommentError(e.toString()));
      }
    }); */
  }
}
