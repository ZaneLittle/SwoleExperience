import 'package:swole_experience/model/workout.dart';

/// Uses the Brzycki formula
class WeightUtil {

  static int calculateOneRepMax(Workout workout) {
    double oneRepMax = calculateExactOneRepMax(workout);
    return oneRepMax.round().toInt();
  }

  static double calculateExactOneRepMax(Workout workout) {
    return workout.weight*(36/(37-workout.reps));
  }

  static double calculateWeightForReps(int reps, double oneRepMax) {
    return 1/((36/(37-reps))/oneRepMax);
  }

}