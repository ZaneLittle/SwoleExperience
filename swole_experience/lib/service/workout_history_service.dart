import 'dart:io';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/model/workout_history.dart';
import 'package:swole_experience/util/converter.dart';

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

  static final Logger logger = Logger();

  WorkoutHistoryService._privateConstructor();

  static final WorkoutHistoryService svc =
      WorkoutHistoryService._privateConstructor();

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

  Future<void> _addSupersetField(Database db) async {
    await db.execute('ALTER TABLE $_dbName ADD supersetParentId TEXT;');
  }

  Future<void> _addAltField(Database db) async {
    await db.execute('ALTER TABLE $_dbName ADD altParentId TEXT;');
  }

  Future<void> _handleError(DatabaseException e, int retries, Database db,
      WorkoutHistory workout) async {
    logger.e('Error inserting $workout. Error: $e');
    if (e.toString().contains('no column named supersetParentId') &&
        retries > 0) {
      logger.i('Attempting to add supersetParentId field and retrying');
      return await _addSupersetField(db);
    } else if (e.toString().contains('no column named altParentId') &&
        retries > 0) {
      logger.i('Attempting to add supersetParentId field and retrying');
      return await _addAltField(db);
    } else {
      throw e;
    }
  }

  /// Queries workout history
  /// @param date - if provided, only instances for this date will be returned
  /// @param startDate - if provided, instances will be queried @param dayLimit
  ///   number of days from @startDate.
  /// @param dayLimit - if provided, the query will reach back @dayLimit many days
  ///   if not provided, the default is 90 if
  Future<List<WorkoutHistory>> getWorkoutHistory(
      {String? date, DateTime? startDate, int? dayLimit}) async {
    Database db = await svc.db;

    String? where;
    List<Object?>? whereArgs;
    if (date != null) {
      where = '"date" = ?';
      whereArgs = [date];
    } else {
      String dateBound = startDate != null
          ? startDate.subtract(const Duration(days: 180)).toString()
          : DateTime.now().subtract(const Duration(days: 180)).toString();

      if (startDate != null) {
        String startDateStr = Converter().roundToNextDay(startDate).toString();

        where = '"date" >= ? AND "date" <= ?';
        whereArgs = [dateBound, startDateStr];
      } else {
        where = '"date" >= ?';
        whereArgs = [dateBound];
      }
    }

    var workouts = await db.query(
      _dbName,
      where: where,
      whereArgs: whereArgs,
    );

    return workouts.isNotEmpty
        ? workouts.map((w) => WorkoutHistory.fromMap(w)).toList()
        : [];
  }

  /// Queries workout history and returns a map of unique items
  /// @param date - if provided, only instances for this date will be returned
  /// @param startDate - if provided, instances will be queried @param dayLimit
  ///   number of days from @startDate.
  /// @param dayLimit - if provided, the query will reach back @dayLimit many days
  ///   if not provided, the default is 90 if
  Future<Map<String, List<WorkoutHistory>>> getWorkoutHistoryMap(
      {String? date, DateTime? startDate, int? dayLimit}) async {

    List<WorkoutHistory> workoutList = await getWorkoutHistory(
        date: date, startDate: startDate, dayLimit: dayLimit);

    Map<String, List<WorkoutHistory>> workoutMap = {};
    for (WorkoutHistory workout in workoutList) {
      workoutMap[workout.workoutId] == null
          ? workoutMap[workout.workoutId] = [workout]
          : workoutMap[workout.workoutId]!.add(workout);
    }

    return workoutMap;
  }

  Future<int> createWorkoutHistory(WorkoutHistory workout,
      {int retries = 2}) async {
    Database db = await svc.db;
    try {
      return await db.insert(_dbName, workout.toMap());
    } on DatabaseException catch (e, _) {
      return _handleError(e, retries, db, workout)
          .then((_) => createWorkoutHistory(workout, retries: retries - 1));
    }
  }

  Future<int> updateWorkoutHistory(WorkoutHistory workout,
      {int retries = 2}) async {
    Database db = await svc.db;
    try {
      return await db.update(_dbName, workout.toMap(),
          where: 'id = ?', whereArgs: [workout.id]);
    } on DatabaseException catch (e, _) {
      return _handleError(e, retries, db, workout)
          .then((_) => updateWorkoutHistory(workout, retries: retries - 1));
    }
  }
}
