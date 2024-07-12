import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pulse/core/utils/formatters.dart';

class UserProfilePostHeader extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String timestamp;
  final VoidCallback? onTap;

  const UserProfilePostHeader({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 20,
              child: CachedNetworkImage(
                imageUrl: profileImageUrl ??
                    'https://image-uniservice.linternaute.com/image/450/4/1708793598/8469657.jpg',
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
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                formatTimestamp(timestamp),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
