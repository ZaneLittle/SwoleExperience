import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/model/workout_history.dart';


/// WeightHistoryService provides an interface to the `workouthistory` table.
/// This table stores the workouts the user has completed
/// Weight = {
///   TEXT id               = uuid for the workouthistory record
///   TEXT workoutId        = uuid of the workout (foreign key on table `workout`)
///   TEXT date             = Date the workout was performed, represented as a string
///   TEXT name             = Name of the exercise
///   FLOAT weight          = Weight for the exercise
///   INTEGER sets          = number of sets to perform
///   INTEGER reps          = number of reps to aim for
///   TEXT notes            = Any notes the user wants to add to this record
///   TEXT supersetParentId = ID of a superset workout object (Comes before)
///   TEXT altParentId      = ID of an alternative set (takes priority)
/// }
/// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/supported_types.md
class WorkoutHistoryService {
  static const String _dbName = 'workouthistory';

  WorkoutHistoryService._privateConstructor();

  static final WorkoutHistoryService svc = WorkoutHistoryService._privateConstructor();

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
        workoutId TEXT,
        date TEXT,
        name TEXT,
        weight FLOAT,
        sets INTEGER,
        reps INTEGER,
        notes TEXT,
        supersetParentId TEXT,
        altParentId TEXT
        )
    ''');
  }

  /// Queries workout history
  /// If given a date, it will only return the workout(s) for that date
  Future<List<WorkoutHistory>> getWorkoutHistory({String? date}) async {
    Database db = await svc.db;

    var workouts = date != null
        ? await db.query(
            _dbName,
            where: 'date = ?',
            whereArgs: [date],
          )
        : await db.query(
            _dbName,
            orderBy: 'date DESC',
          );

    return workouts.isNotEmpty
        ? workouts.map((w) => WorkoutHistory.fromMap(w)).toList()
        : [];
  }

  Future<int> createWorkoutHistory(WorkoutHistory workout) async {
    Database db = await svc.db;
    return await db.insert(_dbName, workout.toMap());
  }

  Future<int> removeWorkoutHistory(String id) async {
    Database db = await svc.db;
    return await db.delete(_dbName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWorkoutHistory(WorkoutHistory workout) async {
    Database db = await svc.db;
    return await db.update(_dbName, workout.toMap(),
        where: 'id = ?', whereArgs: [workout.id]);
  }
}
