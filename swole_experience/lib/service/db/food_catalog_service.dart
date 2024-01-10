import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/model/food.dart';

/// Stores and surfaces the collection of foods the user has used / created
class FoodCatalogService {
  static const String _dbName = 'food';
  static final Logger logger = Logger();

  FoodCatalogService._privateConstructor();

  static final FoodCatalogService svc =
      FoodCatalogService._privateConstructor();

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
        carbs FLOAT,
        amount FLOAT,
        unit TEXT,
        customUnit TEXT,
        gramConversion FLOAT
        )
    ''');
  }

  Future<List<Food>> search({String? query}) async {
    Database db = await svc.db;

    var results = await db.query(
      _dbName,
      orderBy:
          'lastUpdated DESC', // TODO: Is this desired behaviour? can/should we sort by relevance?
      where:
          '"name" LIKE ?', // OR "brand" LIKE %$query%', // TODO: y no work
      whereArgs: ['%$query%'],
    ).catchError((e, st) {
      logger.e(e);
      return {};
    });

    return results.isNotEmpty
        ? results.map((r) => Food.fromMap(r)).toList()
        : [];
  }

  Future<String?> createOrUpdate(Food food) async {
    Database db = await svc.db;

    food.lastUpdated = DateTime.now();
    Map<String, dynamic> toInsert = food.toMap();
    // Food toInsert = Food({...food, lastUpdated: DateTime.now()}); TODO: I'd like to do something more like this and keep lastUpdated final

    String? err;
    int res = await db.update(
      _dbName,
      toInsert,
      where: '"id" = ?',
      whereArgs: [food.id],
    ).catchError((e) {
      logger.e('Error updating food ${food.id}: $e');
      err = '$e';
      return 0;
    });

    res = (res == 0) ? await db.insert(_dbName, toInsert).catchError((e) {
      logger.e('Error creating food ${food.id}: $e');
      String? existingErr = err;
      err = 'Error creating food ${food.name}: $e';
      if (existingErr != null) {
        err = '$err, $existingErr';
      }
      return 0;
    }) : res;

    return res == 0 ? err : null;
  }

  Future<String?> delete(String id) async {
    Database db = await svc.db;
    String? err;
    await db.delete(_dbName, where: 'id = ?', whereArgs: [id]).onError((e, st) {
      logger.e('Error deleting $id: $e');
      err = '$e';
      return 0;
    });

    return err;
  }
}
