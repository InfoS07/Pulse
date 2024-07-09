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
  final GetCommentsUc _getCommentsUc;
  final AddCommentUc _addCommentUc;

  CommentBloc(
      {required GetCommentsUc getCommentsUc,
      required AddCommentUc addCommentUc})
      : _getCommentsUc = getCommentsUc,
        _addCommentUc = addCommentUc,
        super(CommentInitial()) {
    on<GetComments>(_onGetComments);
    on<AddCommentEvent>(_onAddComment);

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

  void _onAddComment(
    AddCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    //emit(CommentLoading());
    final res = await _addCommentUc(AddCommentParams(
      event.trainingId,
      AddComment(text: event.text),
    ));

    res.fold(
      (l) => emit(CommentError(l.message)),
      (r) {
        final currentState = state;
        if (currentState is CommentLoaded) {
          final updatedComments = List<Comment>.from(currentState.comments)
            ..add(r);
          emit(CommentLoaded(updatedComments));
        }
      },
    );
  }

  void _onGetComments(
    GetComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final res = await _getCommentsUc(NoParams());

    res.fold(
      (l) => emit(CommentError(l.message)),
      (comments) {
        if (comments.isNotEmpty) {
          emit(CommentLoaded(comments
              .where((comment) => comment != null)
              .cast<Comment>()
              .toList()));
        } else {
          emit(CommentEmpty('Aucun commentaire'));
        }
        ;
      },
    );
  }
}
