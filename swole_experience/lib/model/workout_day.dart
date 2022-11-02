import 'dart:math';

import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/model/workout_history.dart';
import 'package:swole_experience/util/converter.dart';

class WorkoutDay extends Workout {
  WorkoutDay({
    required id,
    required this.day,
    required this.dayOrder,
    required name,
    required weight,
    required sets,
    required reps,
    notes,
    supersetParent,
    supersetChild,
    altParent,
    altChild,
  }) : super(
          id: id,
          name: name,
          weight: weight,
          sets: sets,
          reps: reps,
          notes: notes,
          supersetParent: supersetParent,
          supersetChild: supersetChild,
          altParent: altParent,
          altChild: altChild,
        );

  final int day;
  final int dayOrder;

  WorkoutDay.fromMap(Map<String, dynamic> map)
      : day = map['day'] as int,
        dayOrder = map['dayOrder'] as int,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> wMap = super.toMap();
    wMap.addAll({
      'day': day,
      'dayOrder': dayOrder,
    });
    return wMap;
  }

  @override
  String toString() {
    return 'WorkoutDay:\n\tWorkout:${super.toString()}\n\tDay:$day\n\tOrder:$dayOrder';
  }

  @override
  WorkoutDay copy({
    String? id,
    int? day,
    int? dayOrder,
    String? name,
    double? weight,
    int? sets,
    int? reps,
    String? notes,
    Workout? supersetParent,
    Workout? supersetChild,
    Workout? altParent,
    Workout? altChild,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      day: day ?? this.day,
      dayOrder: dayOrder ?? this.dayOrder,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      supersetParent: supersetParent ?? this.supersetParent,
      supersetChild: supersetChild ?? this.supersetChild,
      altParent: altParent ?? this.altParent,
      altChild: altChild ?? this.altChild,
    );
  }

  WorkoutHistory toWorkoutHistory({String? historyId, DateTime? date}) {
    DateTime dateToLog = date ?? DateTime.now();
    return WorkoutHistory(
      id: historyId ?? Random().nextInt(9999).toString(),
      workoutId: id,
      date: Converter().truncateToDay(dateToLog).toString(),
      name: name,
      weight: weight,
      sets: sets,
      reps: reps,
      notes: notes,
      supersetParent: supersetParent,
      supersetChild: supersetChild,
      altParent: altParent,
      altChild: altChild,
    );
  }
}
