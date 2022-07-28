import 'package:flutter/cupertino.dart';

import 'package:swole_experience/model/workout.dart';

/// General utility functions
class Util {
  void scrollToSelectedContext(GlobalKey key) {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }

  /// Builds a map of workout days, builds a map of workout days
  ///   - key = day
  ///   - value = list of workouts for that day
  Map<int, List<Workout>> getWorkoutDays(List<Workout> workouts) {
    Map<int, List<Workout>> workoutMap = { };

    for (var workout in workouts) {
      workoutMap[workout.day] != null
          ? workoutMap[workout.day]!.add(workout)
          : workoutMap[workout.day] = [workout];
    }

    return workoutMap;
  }
}