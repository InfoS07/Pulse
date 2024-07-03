import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/entities/like.dart';

class LikesPage extends StatelessWidget {
  final List<Like> likes;

  LikesPage({required this.likes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('J\'aime'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: likes.length,
          itemBuilder: (context, index) {
            final like = likes[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/otherProfil');
                    },
                    child: CircleAvatar(
                      radius: 20,
                      child: CachedNetworkImage(
                        imageUrl: like.profileImageUrl,
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
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      like.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  /* ElevatedButton.icon(
                    onPressed: () {
                      // Action pour suivre / ne plus suivre
                    },
                    icon: like.isFollowing
                        ? Icon(Icons.check, color: Colors.white)
                        : Icon(Icons.add, color: Colors.white),
                    label: Text(
                      like.isFollowing ? 'Suivi' : 'Suivre',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          like.isFollowing ? Colors.grey : Colors.greenAccent,
                      side: BorderSide(
                          color: like.isFollowing
                              ? Colors.grey
                              : Colors.greenAccent),
                    ),
                  ), */
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
