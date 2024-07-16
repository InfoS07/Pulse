import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:shimmer/shimmer.dart';

class ExerciseCard extends StatelessWidget {
  final Exercice exercise;
  final VoidCallback onTap;
  final VoidCallback onLockedTap;
  final bool isLocked;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onLockedTap,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? onLockedTap : onTap,
      child: Stack(
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: isLocked
                        ? Border.all(color: AppPallete.secondaryColor, width: 4)
                        : null,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: exercise.photos.firstWhere(
                          (element) => !element.endsWith('.mp4'),
                          orElse: () => exercise.photos.first),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        enabled: true,
                        child: Container(
                          color: Colors.grey[200],
                          height: 120,
                          width: double.infinity,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey,
                        height: 120,
                        width: double.infinity,
                        child: const Center(
                            child: Icon(Icons.error, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${exercise.podCount} Pods',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                /* if (exercise.price > 0)
                  Text(
                    '${exercise.price} points',
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ), */
              ],
            ),
          ),
          if (isLocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppPallete.secondaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const FaIcon(
                  Icons.lock,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          /* if (exercise.price > 0)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  Icons.lock,
                  color: Colors.purple,
                  size: 16,
                ),
              ),
            ), */
        ],
      ),
    );
  }
}

class ExerciseCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Container(
        width: 200,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                height: 120,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 100,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 50,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
