import 'package:swole_experience/model/workout_history.dart';
import 'package:swole_experience/util/converter.dart';


List<WorkoutHistory> getWorkoutHistoryMock() {
  DateTime today = Converter.truncateToDay(DateTime.now());
  return [
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 195.0,
        "reps": 8,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 90)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 195.0,
        "reps": 8,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 84)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 225.0,
        "reps": 4,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 77)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 225.0,
        "reps": 4,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 70)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 215.0,
        "reps": 6,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 63)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 215.0,
        "reps": 6,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 56)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 205.0,
        "reps": 8,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 49)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 205.0,
        "reps": 8,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 42)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 235.0,
        "reps": 4,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 35)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 235.0,
        "reps": 4,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 28)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 220.0,
        "reps": 6,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 21)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 220.0,
        "reps": 6,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 14)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 210.0,
        "reps": 8,
        "sets": 4,
        "workoutId": "4123",
        "date": today.subtract(const Duration(days: 7)).toString(),
      },
      {
        "id": "1234",
        "name": "Bench Press",
        "weight": 210.0,
        "reps": 8,
        "sets": 4,
        "workoutId": "4123",
        "date": today.toString(),
      },
    ].map((w) => WorkoutHistory.fromMap(w)).toList();
}