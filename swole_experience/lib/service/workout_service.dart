import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:swole_experience/model/workout.dart';

/// WeightService provides an interface to the `weight` table.
/// This table stores the raw weight data the user has entered
/// Weight = {
///   TEXT id          = uuid for the record
///   INTEGER day      = Day the exercise is to be performed on
///                     *Note*: Index starts at 1
///                     *Note* Index of 0 means not in use.
///                     TODO: Surface those not in use somehow,
///   INTEGER dayOrder = Order the exercises is intended to be performed in for the day
///                     *Note* Index starts at 1
///   TEXT name        = Name of the exercise
///   FLOAT weight     = Weight for the exercise
///   INTEGER sets     = number of sets to perform
///   INTEGER reps     = number of reps to aim for
///   TEXT notes       = Any notes the user wants to add to this record
/// }
/// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/supported_types.md
class WorkoutService {
  /**
   * TODO: Mocked return data:
   */

  static final List<Workout> mockData = [
    Workout(
        id: '2898',
        day: 1,
        dayOrder: 0,
        name: 'Bench Press',
        weight: 225,
        sets: 4,
        reps: 6,
        notes: 'this is a note'),
    Workout(
        id: '1898',
        day: 1,
        dayOrder: 1,
        name: 'Deadlift',
        weight: 405,
        sets: 4,
        reps: 6,
        notes:
            '"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'),
    Workout(
      id: '2891',
      day: 1,
      dayOrder: 2,
      name: 'Squat',
      weight: 315,
      sets: 4,
      reps: 6,
    ),
    Workout(
      id: '2198',
      day: 1,
      dayOrder: 3,
      name: 'OHP',
      weight: 135,
      sets: 3,
      reps: 8,
    ),
    Workout(
      id: '8847',
      day: 1,
      dayOrder: 3,
      name: 'Curls',
      weight: 60,
      sets: 3,
      reps: 12,
    ),
    Workout(
        id: '3051',
        day: 1,
        dayOrder: 3,
        name: 'Rows',
        weight: 135,
        sets: 4,
        reps: 6,
        notes: "This is a two line note\n - hello"),
    Workout(
        id: '9666',
        day: 1,
        dayOrder: 3,
        name: 'Incline Press',
        weight: 65,
        sets: 3,
        reps: 8,
        notes:
            "This is a multi line note\nthis is the second line \nWe have a third line here"),
  ];

  /**
   * TODO: END
   */

  static const String _dbName = 'workout';

  WorkoutService._privateConstructor();

  static final WorkoutService svc = WorkoutService._privateConstructor();

  static Database? _db;

  Future<Database> get db async => _db ??= await _initDb();

  Future<Database> _initDb() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    String path = join(docDir.path, '$_dbName.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Creates new database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_dbName(
        id TEXT PRIMARY KEY,
        day INTEGER,
        dayOrder INTEGER,
        name TEXT,
        weight FLOAT,
        sets INTEGER,
        reps INTEGER,
        notes TEXT   
        )
    ''');
  }

  /// Queries workouts, if given a day, it will only return the workouts for that day
  Future<List<Workout>> getWorkouts({int? day}) async {
    Database db = await svc.db;

    var workouts = day != null
        ? await db.query(
            _dbName,
            orderBy: 'dayOrder',
            where: 'day = ?',
            whereArgs: [day],
          )
        : await db.query(
            _dbName,
            orderBy: 'dayOrder',
          );

    return workouts.isNotEmpty
        ? workouts.map((w) => Workout.fromMap(w)).toList()
        : [];
    // return mockData;
  }

  /// Returns the number of unique days contained in the workouts
  Future<int> getUniqueDays() async {
    Database db = await svc.db;

    var days = await db.query(_dbName, columns: ['day'], groupBy: 'day');

    return days.length;
  }

  Future<int> createWorkout(Workout workout) async {
    Database db = await svc.db;
    return await db.insert(_dbName, workout.toMap());
  }

  Future<int> removeWorkout(String id) async {
    Database db = await svc.db;
    return await db.delete(_dbName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWorkout(Workout workout) async {
    Database db = await svc.db;
    return await db.update(_dbName, workout.toMap(),
        where: 'id = ?', whereArgs: [workout.id]);
  }
}
