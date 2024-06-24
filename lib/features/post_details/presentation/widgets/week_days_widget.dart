import 'package:flutter/material.dart';

class WeekDaysWidget extends StatelessWidget {
  final List<String> days = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];
  final List<bool> activeDays = [
    true,
    true,
    false,
    false,
    false,
    false,
    false
  ]; // Exemples de jours actifs

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(days.length, (index) {
          return Column(
            children: [
              Text(
                days[index],
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: activeDays[index] ? Colors.greenAccent : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
