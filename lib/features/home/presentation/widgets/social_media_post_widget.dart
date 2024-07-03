import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';

class SocialMediaPostWidget extends StatefulWidget {
  final SocialMediaPost post;
  final VoidCallback onTap;

  SocialMediaPostWidget({required this.post, required this.onTap});

  @override
  _SocialMediaPostWidgetState createState() => _SocialMediaPostWidgetState();
}

class _SocialMediaPostWidgetState extends State<SocialMediaPostWidget> {
  void toggleLike() {
    setState(() {
      print('Like post ${widget.post.id}');
      BlocProvider.of<HomeBloc>(context).add(LikePost(widget.post.id));
      if (widget.post.isLiked) {
        //widget.post.likes++;
      } else {
        //widget.post.likes--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Définir l'action du callback
      child: Container(
        padding: EdgeInsets.all(16.0),
        color: AppPallete.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Ajouter l'action de navigation
                    //context.push('/otherProfil');
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
              widget.post.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '9,38 km', // Example value, replace with your actual data
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temps',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '50min 4s', // Example value, replace with your actual data
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.post.postImageUrl.isNotEmpty) ...[
              SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                child: Container(
                  height: 100, // Hauteur fixe de 100 pixels
                  child: CachedNetworkImage(
                    imageUrl: widget.post.postImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ],
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: toggleLike,
                  child: Icon(
                    Icons.thumb_up,
                    color: widget.post.isLiked ? Colors.green : Colors.white,
                  ),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    context.push('/home/details/1/likes',
                        extra: widget.post.likes);
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
