import 'package:swole_experience/model/workout.dart';

class WorkoutHistory extends Workout {
  WorkoutHistory({
    required id,
    required this.workoutId,
    required this.date,
    required name,
    required weight,
    required sets,
    required reps,
    notes,
  }) : super(id: id, name: name, weight: weight, sets: sets, reps: reps, notes: notes);

  final String workoutId;
  final String date;

  WorkoutHistory.fromMap(Map<String, dynamic> map)
      : workoutId =  map['workoutId'] as String,
        date = map['date'] as String,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> wMap = super.toMap();
    wMap.addAll({
      'workoutId': workoutId,
      'date': date,

    });
    return wMap;
  }

  @override
  String toString() {
    return 'WorkoutHistory:\n\tWorkout:${super.toString()}\n\tWorkout ID:$workoutId\n\tDate:$date';
  }

  @override
  WorkoutHistory copy({
    String? id,
    String? workoutId,
    String? date,
    String? name,
    double? weight,
    int? sets,
    int? reps,
    String? notes,
  }) {
    return WorkoutHistory(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      date: date ?? this.date,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
    );
  }
}