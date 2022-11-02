import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:swole_experience/model/workout_day.dart';

/// WorkoutService provides an interface to the `workout` table.
/// This table stores the recurring workouts the user has configured
/// Weight = {
///   TEXT id          = uuid for the record
///   INTEGER day      = Day the exercise is to be performed on
///                     *Note*: Index starts at 1
///                     *Note* Index of 0 means not in use.
///                     TODO: Surface those not in use somehow,
///   INTEGER dayOrder = Order the exercises is intended to be performed in for the day
///                     *Note* Index starts at 1
///   TEXT name             = Name of the exercise
///   FLOAT weight          = Weight for the exercise
///   INTEGER sets          = number of sets to perform
///   INTEGER reps          = number of reps to aim for
///   TEXT notes            = Any notes the user wants to add to this record
///   TEXT supersetParentId = ID of a superset workout object (Comes before)
///   TEXT supersetChildId  = ID of a superset workout object (Comes after)
///   TEXT altSetParentId   = ID of an alternative set (takes priority)
///   TEXT altSetChildId    = ID of an alternative set (foreign object takes priority)
/// }
/// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/supported_types.md
class WorkoutService {
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
        notes TEXT,
        supersetParentId TEXT,
        supersetChildId TEXT,
        altSetParentId TEXT,
        altSetChildId TEXT        
        )
    ''');
  }

  /// Queries workouts, if given a day, it will only return the workouts for that day
  Future<List<WorkoutDay>> getWorkouts({int? day}) async {
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
        ? workouts.map((w) => WorkoutDay.fromMap(w)).toList()
        : [];
  }

  /// Returns the number of unique days contained in the workouts
  Future<int> getUniqueDays() async {
    Database db = await svc.db;

    var days = await db.query(_dbName, columns: ['day'], groupBy: 'day');

    return days.length;
  }

  Future<int> createWorkout(WorkoutDay workout) async {
    Database db = await svc.db;
    return await db.insert(_dbName, workout.toMap());
  }

  Future<int> removeWorkout(String id) async {
    Database db = await svc.db;
    return await db.delete(_dbName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWorkout(WorkoutDay workout) async {
    Database db = await svc.db;
    return await db.update(_dbName, workout.toMap(),
        where: 'id = ?', whereArgs: [workout.id]);
  }
}
