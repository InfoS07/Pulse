import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse/features/comments/presentation/bloc/comment_bloc.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/formatters.dart';

class CommentsPage extends StatefulWidget {
  final SocialMediaPost post;

  const CommentsPage({super.key, required this.post});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  String _selectedReportReason = '';

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(GetComments());
  }

  void _showReportModalBottomSheet(BuildContext context, int commentId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: AppPallete.backgroundColor,
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.report, color: Colors.red),
                title: Text('Signaler', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context, commentId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, int commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Signaler le commentaire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportOption('Caractère sexuel'),
              _buildReportOption('Inapproprié'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Handle the report action
                Navigator.of(context).pop();
                context
                    .read<CommentBloc>()
                    .add(ReportCommentEvent(commentId, _selectedReportReason));
              },
              child: Text('Signaler'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String reason) {
    return ListTile(
      title: Text(reason),
      trailing: Icon(
        _selectedReportReason == reason
            ? Icons.check_box
            : Icons.check_box_outline_blank,
        color: _selectedReportReason == reason ? Colors.green : null,
      ),
      onTap: () {
        setState(() {
          _selectedReportReason = reason;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserProfilePostContainer(
            profileImageUrl: widget.post.profileImageUrl,
            username: widget.post.username,
            timestamp: widget.post.timestamp,
            title: widget.post.title,
            commentCount: widget.post.comments.length,
            onTap: () {
              //context.push('/otherProfil');
            },
          ),
          Expanded(
            child: BlocConsumer<CommentBloc, CommentState>(
              listener: (context, state) {
                if (state is CommentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is CommentInitial || state is CommentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CommentLoaded) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) {
                            final comment = state.comments[index];
                            return Container(
                              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      comment.user.urlProfilePhoto),
                                ),
                                title: Text(
                                  comment.user.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(comment.content),
                                trailing: IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {
                                    _showReportModalBottomSheet(
                                        context, comment.id);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Écrire un commentaire...',
                                    filled: true,
                                    fillColor: AppPallete.backgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Le commentaire ne peut pas être vide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    context
                                        .read<CommentBloc>()
                                        .add(AddCommentEvent(
                                          widget.post.id,
                                          commentController.text,
                                        ));
                                    commentController.clear();
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is CommentError) {
                  return Center(child: Text(state.message));
                } else if (state is CommentEmpty) {
                  return Column(
                    children: [
                      Expanded(
                        child: Center(child: Text(state.message)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Écrire un commentaire...',
                                    filled: true,
                                    fillColor: AppPallete.backgroundColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Le commentaire ne peut pas être vide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    context
                                        .read<CommentBloc>()
                                        .add(AddCommentEvent(
                                          widget.post.id,
                                          commentController.text,
                                        ));
                                    commentController.clear();
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('Erreur !'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfilePostContainer extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final String title;
  final int commentCount;
  final VoidCallback onTap;

  UserProfilePostContainer({
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    required this.title,
    required this.commentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPallete.backgroundColor,
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserProfilePostHeader(
            profileImageUrl: profileImageUrl,
            username: username,
            timestamp: timestamp,
            onTap: onTap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfilePostHeader extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final VoidCallback onTap;

  UserProfilePostHeader({
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profileImageUrl),
      ),
      title: Text(
        username,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        formatTimestamp(timestamp),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      ),
      onTap: onTap,
    );
  }
}
