import 'package:flutter/material.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class SessionCardWidget extends StatelessWidget {
  final String title;
  final String duration;
  final String points;
  final VoidCallback onStart;

  SessionCardWidget({
    required this.title,
    required this.duration,
    required this.points,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.0,
      /* margin: EdgeInsets.all(16.0), */
      /* padding: EdgeInsets.all(16.0), */
      decoration: BoxDecoration(
        color: Colors.black, // Couleur de fond de la carte
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppPallete.primaryColor.withOpacity(0.8),
          width: 2.0,
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
      child: Stack(
        children: [
          Container(
              /* decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                colors: [
                  AppPallete.primaryColor.withOpacity(0.4),
                  Color.fromARGB(0, 175, 238, 39)
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ), */
              ),
          Padding(
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
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white),
                    SizedBox(width: 8.0),
                    Text(duration, style: TextStyle(color: Colors.white)),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: /* AppPallete.primaryColor.withOpacity(
                            0.2), // */
                            Color.fromARGB(255, 193, 113, 227).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        '+$points points',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'C\'est parti !',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
