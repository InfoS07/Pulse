import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pulse/core/common/entities/exercice.dart';

class ExerciseCard extends StatelessWidget {
  final Exercice exercise;
  final VoidCallback onTap;

  ExerciseCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              child: CachedNetworkImage(
                imageUrl: exercise.urlPhoto,
                height: 100,
                width: double.infinity, // Make the image take full width
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200], // Placeholder color
                  height: 100,
                  width: double.infinity,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey, // Error color
                  height: 100,
                  width: double.infinity,
                  child: Center(child: Icon(Icons.error, color: Colors.white)),
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${exercise.podCount} Pods',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const FaIcon(
                  FontAwesomeIcons.fire,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
