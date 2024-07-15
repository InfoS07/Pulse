import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuzzerIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const BuzzerIndicator({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            isActive ? color.withOpacity(0.8) : Colors.grey.withOpacity(0.8),
            isActive ? color : Colors.grey,
          ],
          center: Alignment(-0.3, -0.5),
          radius: 1,
        ),
        border: Border.all(
          color: isActive ? Colors.black : Colors.grey.shade800,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      width: 150,
      height: 150,
    );
  }
}

class BuzzerRow extends StatelessWidget {
  final List<Color> activeBuzzers;

  const BuzzerRow({required this.activeBuzzers});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: activeBuzzers
          .map((buzzerColor) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BuzzerIndicator(
                  isActive: true,
                  color: buzzerColor,
                ),
              ))
          .toList(),
    );
  }
}
