import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/unit.dart';

/// Stores and surfaces the collection of foods the user has used / created
class FoodCatalogService {
  static const String _dbName = 'food';

  FoodCatalogService._privateConstructor();

  static final FoodCatalogService svc = FoodCatalogService._privateConstructor();

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
        barcode INTEGER,
        lastUpdated TEXT,
        name TEXT,
        brand TEXT,
        calories FLOAT,
        protein FLOAT,
        fat FLOAT,
        carbs FLOAT
        )
    ''');
  }

  Future<List<Food>> search({String? query}) {
    return Future.value([
      Food(
        id: '123',
        name: query ?? 'Steak',
        calories: 250,
        protein: 30,
        carbs: 0,
        fat: 20,
        amount: 100.0,
        unit: Unit.g,
        lastUpdated: DateTime.now(),
      ),
      Food(
        id: '1234',
        name: query ?? 'Potatoes',
        brand: 'Chiffon',
        calories: 250,
        protein: 30,
        carbs: 0,
        fat: 20,
        amount: 100.0,
        unit: Unit.g,
        lastUpdated: DateTime.now(),
      ),
      Food(
        id: '12345',
        name: query ?? 'Salad',
        calories: 250,
        protein: 30,
        carbs: 0,
        fat: 20,
        amount: 100.0,
        unit: Unit.g,
        lastUpdated: DateTime.now(),
      ),
    ]);
  }
}
