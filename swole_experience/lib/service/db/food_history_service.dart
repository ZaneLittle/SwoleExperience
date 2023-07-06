import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/model/food_history.dart';
import 'package:swole_experience/model/unit.dart';

/// Stores and surfaces the collection of foods the user has used / created
class FoodHistoryService {
  static const String _dbName = 'foodhistory';

  FoodHistoryService._privateConstructor();

  static final FoodHistoryService svc = FoodHistoryService._privateConstructor();

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
        foodId TEXT,
        mealNumber INTEGER,
        date TEXT,
        exactTime TEXT,
        name TEXT,
        calories FLOAT,
        protein FLOAT,
        fat FLOAT,
        carbs FLOAT,
        amount FLOAT,
        unit STRING,
        )
    ''');
  }

  Future<List<FoodHistory>> get({DateTime? date}) {
    return Future.value([FoodHistory(
      id: '123',
      name: 'Steak',
      calories: 250,
      protein: 30,
      carbs: 0,
      fat: 20,

      amount: 100,
      unit: Unit.g,
      foodId: '123',
      mealNumber: 1,
      date: DateTime.now(),
    )]);
  }
}
