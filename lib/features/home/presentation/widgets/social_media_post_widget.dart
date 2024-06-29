import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/comment.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class SocialMediaPost {
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final String title;
  final String content;
  final String postImageUrl;
  int likes;
  final List<Comment> comments;

  SocialMediaPost({
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    required this.title,
    required this.content,
    required this.postImageUrl,
    required this.likes,
    required this.comments,
  });
}

class SocialMediaPostWidget extends StatefulWidget {
  final SocialMediaPost post;
  final VoidCallback onTap;

  SocialMediaPostWidget({required this.post, required this.onTap});

  @override
  _SocialMediaPostWidgetState createState() => _SocialMediaPostWidgetState();
}

class _SocialMediaPostWidgetState extends State<SocialMediaPostWidget> {
  bool isLiked = false;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        widget.post.likes++;
      } else {
        widget.post.likes--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Définir l'action du callback
      child: Container(
        padding: EdgeInsets.all(16.0),
        color: Color.fromARGB(221, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context.push('/otherProfil');
                  },
                  child: CircleAvatar(
                    radius: 20,
                    child: CachedNetworkImage(
                      imageUrl: widget.post.profileImageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.post.timestamp,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 22),
            Text(
              widget.post.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              widget.post.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              child: CachedNetworkImage(
                imageUrl: widget.post.postImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: toggleLike,
                  child: Icon(
                    Icons.thumb_up,
                    color: isLiked ? Colors.green : Colors.white,
                  ),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    context.push('/home/details/1/likes');
                  },
                  child: Text(
                    widget.post.likes.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 18),
                GestureDetector(
                  onTap: () {
                    context.push('/home/details/1/comments',
                        extra: widget.post.comments);
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          '${widget.post.comments.length}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
