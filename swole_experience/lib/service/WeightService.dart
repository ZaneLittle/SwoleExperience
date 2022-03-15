import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/Weight.dart';

class WeightService {
  static const String _dbName = 'weight';

  WeightService._privateConstructor();

  static final WeightService svc =
      WeightService._privateConstructor();

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

  /**
   * Creates new database
   *
   * Note: dateTime is stored as TEXT since DATETIME is not supported: https://github.com/tekartik/sqflite/blob/master/sqflite/doc/supported_types.md
   */
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_dbName(
        id TEXT PRIMARY KEY,
        dateTime TEXT,
        weight FLOAT
        )
    ''');
  }

  Future<List<Weight>> getWeights() async {
    Database db = await svc.db;
    var weights = await db.query(_dbName, orderBy: 'dateTime DESC');

    List<Weight> weightList = weights.isNotEmpty
        ? weights.map((c) => Weight.fromMap(c)).toList()
        : [];
    return weightList;
  }

  Future<int> addWeight(Weight weight) async {
    Database db = await svc.db;
    return await db.insert(_dbName, weight.toMap());
  }
}
