import 'package:flutter/material.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class ExerciseHomeCardWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onStart;

  ExerciseHomeCardWidget({
    required this.imageUrl,
    required this.title,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      /* decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ), */

      decoration: BoxDecoration(
        color: Colors.black, // Couleur de fond de la carte
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppPallete.primaryColor.withOpacity(0.8),
          width: 2.0,
        ),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
        /* boxShadow: [
          BoxShadow(
            color: AppPallete.primaryColor.withOpacity(0.8),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: Offset(0, 4),
          ),
        ], */
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Commencer',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
