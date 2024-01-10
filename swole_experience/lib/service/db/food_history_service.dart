import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/model/food_history.dart';
import 'package:swole_experience/util/converter.dart';

/// Stores and surfaces the collection of foods the user has used / created
class FoodHistoryService {
  final Logger logger = Logger();

  static const String _dbName = 'foodhistory';

  FoodHistoryService._privateConstructor();

  static final FoodHistoryService svc =
      FoodHistoryService._privateConstructor();

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
        fdcId TEXT,
        foodId TEXT,
        name TEXT,
        brand TEXT,
        calories FLOAT,
        protein FLOAT,
        fat FLOAT,
        carbs FLOAT,
        amount FLOAT,
        unit TEXT,
        customUnit TEXT,
        gramConversion FLOAT,
        mealNumber INTEGER,
        date TEXT,
        barcode TEXT,
        lastUpdated TEXT,
        exactTime TEXT
        )
    ''');
  }

  Future<List<FoodHistory>> get(
      {String? id, String? name, DateTime? date}) async {
    Database db = await svc.db;
    List<String> where = [];
    List<Object?>? whereArgs = [];

    if (id != null) {
      where.add('"id" = ?');
      whereArgs.add(id);
    }
    if (name != null) {
      where.add('"name" = ?');
      whereArgs.add(name);
    }
    if (date != null) {
      where.add('"date" = ?');
      whereArgs.add(Converter.truncateToDay(date).toString());
    }

    var foodHistory = await db.query(
      _dbName,
      where: where.join(' AND '),
      whereArgs: whereArgs,
    );

    return foodHistory.isNotEmpty
        ? foodHistory.map((f) => FoodHistory.fromMap(f)).toList()
        : [];
  }

  Future<String?> create(FoodHistory food) async {
    Database db = await svc.db;
    String? e;
    await db.insert(_dbName, food.toMap()).onError((err, st) {
      logger.e('Error creating a food history item: $err');
      e = '$err';
      return 0;
    });
    return e;
  }
}
