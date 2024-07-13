import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/core/utils/formatters.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';

class CommentsPage extends StatefulWidget {
  final int postId;

  const CommentsPage({super.key, required this.postId});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  String _selectedReportReason = '';

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
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReportOption('Caractère sexuel', setState),
                  _buildReportOption('Inapproprié', setState),
                  _buildReportOption('Racisme', setState),
                  _buildReportOption('Offensant', setState),
                ],
              );
            },
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
                context
                    .read<HomeBloc>()
                    .add(ReportCommentEvent(commentId, _selectedReportReason));
                Navigator.of(context).pop();
              },
              child: Text('Signaler'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String reason, StateSetter setState) {
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discussion'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              final post =
                  state.posts.firstWhere((post) => post!.id == widget.postId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserProfilePostContainer(
                    profileImageUrl: post!.profileImageUrl,
                    username: post.username,
                    timestamp: post.timestamp,
                    title: post.title,
                    commentCount: post.comments.length,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  Expanded(
                    child: post.comments.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                    image:
                                        AssetImage('assets/images/friends.png'),
                                    width: 150),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun commentaire pour le moment',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: post.comments.length,
                            itemBuilder: (context, index) {
                              final comment = post.comments[index];
                              return Container(
                                margin:
                                    const EdgeInsets.fromLTRB(8.0, 8.0, 0, 0),
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
                                BlocProvider.of<HomeBloc>(context).add(
                                  AddCommentToPostEvent(
                                    post.id,
                                    commentController.text,
                                  ),
                                );
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
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
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
