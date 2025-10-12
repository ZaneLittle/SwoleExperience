import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FoodService {
  static const String _dbName = 'food';

  FoodService._privateConstructor();

  static final FoodService svc = FoodService._privateConstructor();

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
        fdcId INTEGER,
        lastUpdated TEXT,
        name TEXT,
        brand TEXT,
        calories FLOAT,
        protein FLOAT,
        fat FLOAT,
        carbohydrates FLOAT
        )
    ''');
  }
}
