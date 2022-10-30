import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:swole_experience/components/AlertSnackBar.dart';
import 'package:swole_experience/model/workout_day.dart';

/// General utility functions
class Util {
  static final Logger logger = Logger();

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
  /// Note: Returned map is unordered at the day level
  Map<int, List<WorkoutDay>> getWorkoutDays(List<WorkoutDay> workouts) {
    Map<int, List<WorkoutDay>> workoutMap = { };

    for (var workout in workouts) {
      workoutMap[workout.day] != null
          ? workoutMap[workout.day]!.add(workout)
          : workoutMap[workout.day] = [workout];
    }

    return workoutMap;
  }


  /// Navigates to a provided external URL
  static Future launchExternalUrl(Uri url, BuildContext context) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      logger.e("Failed to launch $url");
      AlertSnackBar(
        message: 'Unable to launch $url.',
        state: SnackBarState.failure,
      ).alert(context);
    }
  }
}

