import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pulse/core/common/entities/difficulty.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:shimmer/shimmer.dart';

class ExerciseCard extends StatelessWidget {
  final Exercice exercise;
  final VoidCallback onTap;

  const ExerciseCard({super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              child: CachedNetworkImage(
                imageUrl: exercise.photos.firstWhere(
                    (element) => !element.endsWith('.mp4'),
                    orElse: () => exercise.photos.first),
                height: 120,
                width: double.infinity, // Make the image take full width
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  enabled: true,
                  child: Container(
                    color: Colors.grey[200], // Placeholder color
                    height: 120,
                    width: double.infinity,
                    /* child: const Center(child: CircularProgressIndicator()), */
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey, // Error color
                  height: 120,
                  width: double.infinity,
                  child: const Center(
                      child: Icon(Icons.error, color: Colors.white)),
                ),
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
                    Text(
                      exercise.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${exercise.podCount} Pods',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
                /* FaIcon(
                  size: 16,
                  FontAwesomeIcons.fire,
                  color: exercise.difficulty == Difficulty.easy
                      ? Colors.green
                      : exercise.difficulty == Difficulty.medium
                          ? Colors.orange
                          : Colors.red,
                ), */
              ],
            ),
          ],
        ),
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
                /* FaIcon(
                  size: 16,
                  FontAwesomeIcons.fire,
                  color: Colors.orange,
                ), */
              ],
            ),
          ],
        ),
      ),
    );
  }
}
