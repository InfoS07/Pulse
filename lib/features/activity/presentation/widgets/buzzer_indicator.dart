import 'package:flutter/material.dart';

class BuzzerIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const BuzzerIndicator({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: isActive ? color : Colors.grey,
    );
  }
}
