import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExerciseCardWidget extends StatelessWidget {
  final String exerciseTitle;
  final String exerciseUrlPhoto;
  final VoidCallback onTap;
  final paddingCard;

  ExerciseCardWidget({
    super.key,
    required this.exerciseTitle,
    required this.exerciseUrlPhoto,
    required this.onTap,
    this.paddingCard = const EdgeInsets.symmetric(horizontal: 20.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercice',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Card(
              color: const Color.fromARGB(255, 38, 38, 38),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: CachedNetworkImage(
                    imageUrl: exerciseUrlPhoto,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                title: Text(
                  exerciseTitle,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
