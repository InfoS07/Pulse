import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pulse/core/theme/app_pallete.dart';

class WeekDaysWidget extends StatelessWidget {
  final DateTime startOfWeek;

  WeekDaysWidget({required this.startOfWeek});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        DateTime day = startOfWeek.add(Duration(days: index));
        bool isToday = isSameDay(day, DateTime.now());

        return GestureDetector(
          onTap: () {
            context.push('/home/calendar');
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color:
                      isToday ? AppPallete.primaryColor : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE', 'fr_FR').format(day),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      DateFormat('d', 'fr_FR').format(day),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const Icon(
                      Icons.circle,
                      color: AppPallete.secondaryColor,
                      size: 14.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
      ),
      body: const Center(
        child: Text('Page de calendrier'),
      ),
    );
  }
}
