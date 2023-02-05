import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


/// FavouriteWorkoutService saves the ID of a workout, indicating that it has
/// been "favourited" by the user
/// FavouriteWorkout = {
///   TEXT workoutId
/// }
class FavouriteWorkoutService {
  static const _dbName = 'favouriteWorkouts';

  FavouriteWorkoutService._privateConstructor();

  static final FavouriteWorkoutService svc = FavouriteWorkoutService._privateConstructor();

  static Database? _db;

  Future<Database> get db async => _db ??= await _initDb();

  final Logger logger = Logger();

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
          workoutId TEXT PRIMARY KEY
        )
    ''');
  }

  Future<List<String>> getFavourites() async {
    Database db = await svc.db;

    var res = await db.query(_dbName);

    return  res.map((f) => f['workoutId'].toString()).toList();
  }

  Future<int> addFavourite(String workoutId) async {
    Database db = await svc.db;

    Map<String, String> favourite = {'workoutId': workoutId};

    return await db.insert(_dbName, favourite);
  }

  Future<int> removeFavourite(String workoutId) async {
    Database db = await svc.db;
    return db.delete(_dbName, where: 'workoutId = ?', whereArgs: [workoutId]);
  }
}