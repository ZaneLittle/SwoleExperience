class Toggles {
  static const bool macros = false;
  static const String macrosKey = 'macros';

  static const bool alternativeWorkouts = true;
  static const String alternativeWorkoutsKey = 'alternativeWorkouts';

  static const bool supersets = true;
  static const String supersetsKey = 'supersets';

  static const bool workoutTrends = true;
  static const String workoutTrendsKey = 'workoutTrends';

  static const bool progressionHelper = false;
  static const String progressionHelperKey = 'progressionHelper';


  static Map<String, bool> toggleMap = {
    // macrosKey: Toggles.macros,
    alternativeWorkoutsKey: Toggles.alternativeWorkouts,
    supersetsKey: Toggles.supersets,
    workoutTrendsKey: Toggles.workoutTrends,
    progressionHelperKey: Toggles.progressionHelper,
  };
}
