import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pulse/core/common/entities/difficulty.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pulse/core/common/entities/exercice.dart';



class ExerciseCard extends StatelessWidget {
  final Exercice exercise;
  final VoidCallback onTap;
  final VoidCallback onLockedTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: exercise.price > 0 ? onLockedTap : onTap,
      child: Stack(
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
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
                if (exercise.price > 0)
                  Text(
                    '${exercise.price} points',
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
              ],
            ),
          ),
          if (exercise.price > 0)
            Positioned(
              top: 13,
              right: 13,
              child: const Icon(
                Icons.lock,
                color: Colors.red,
                size: 30,
              ),
            ),
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
