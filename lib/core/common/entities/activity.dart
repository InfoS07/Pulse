import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pulse/core/common/entities/exercice.dart';
import 'package:pulse/core/theme/app_pallete.dart';

Duration calculateReactionTime(DateTime start, DateTime end) {
  return end.difference(start);
}

class ActivityStats {
  final String buzzerExpected;
  final String buzzerPressed;
  final int reactionTime;
  final DateTime pressedAt;

  const ActivityStats({
    required this.buzzerExpected,
    required this.buzzerPressed,
    required this.reactionTime,
    required this.pressedAt,
  });

  @override
  String toString() {
    return 'ActivityStats{buzzerExpected: $buzzerExpected, buzzerPressed: $buzzerPressed, timeElapsed: $reactionTime, pressedAt: $pressedAt}';
  }
}

class Activity extends Equatable {
  final int id;
  final Exercice exercise;
  final int caloriesBurned;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final Duration timer;
  final int touches;
  final int misses;
  final List<ActivityStats> stats;

  const Activity({
    required this.id,
    required this.exercise,
    required this.caloriesBurned,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.timer,
    this.touches = 0,
    this.misses = 0,
    this.stats = const [],
  });

  static Activity empty(Exercice exercice) {
    return Activity(
      id: 0,
      exercise: exercice,
      caloriesBurned: 0,
      status: 'Not Started',
      startAt: DateTime.now(),
      endAt: DateTime.now(),
      createdAt: DateTime.now(),
      timer: Duration.zero,
    );
  }

  Activity copyWith({
    int? id,
    Exercice? exercise,
    int? caloriesBurned,
    String? status,
    int? steps,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    Duration? timer,
    int? touches,
    int? misses,
    List<ActivityStats>? stats,
  }) {
    return Activity(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      status: status ?? this.status,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      timer: timer ?? this.timer,
      touches: touches ?? this.touches,
      misses: misses ?? this.misses,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        id,
        exercise,
        caloriesBurned,
        status,
        startAt,
        endAt,
        createdAt,
        timer,
        touches,
        misses,
      ];
}
