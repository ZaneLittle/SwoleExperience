import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../util/Converter.dart';
import '../model/Weight.dart';

/// WeightService provides an interface to the `weight` table.
/// This table stores the raw weight data the user has entered
/// Weight = {
///   TEXT id       = uuid for weight record
///   FLOAT weight  = weight value the user has entered
///   TEXT dateTime = string representation of the date the record is for
/// }
/// Note: dateTime is stored as TEXT since DATETIME is not supported:
/// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/supported_types.md
class WeightService {
  static const String _dbName = 'weight';

  WeightService._privateConstructor();

  static final WeightService svc = WeightService._privateConstructor();

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
        dateTime TEXT,
        weight FLOAT
        )
    ''');
  }

  /// Queries a 60 day window of weight records, beginning at the start date,
  /// or now if null
  Future<List<Weight>> getWeights({DateTime? startDate}) async {
    Database db = await svc.db;

    String dateBound = startDate != null
        ? startDate.subtract(const Duration(days: 60)).toString()
        : DateTime.now().subtract(const Duration(days: 60)).toString();

    String startDateStr = startDate != null
        ? Converter().roundToNextDay(startDate).toString()
        : Converter().roundToNextDay(DateTime.now()).toString();

    var weights = await db.query(
      _dbName,
      orderBy: 'dateTime DESC',
      where: '"dateTime" >= ? AND "dateTime" <= ?',
      whereArgs: [dateBound, startDateStr],
    );

    return weights.isNotEmpty
        ? weights.map((w) => Weight.fromMap(w)).toList()
        : [];
  }

  Future<int> addWeight(Weight weight) async {
    Database db = await svc.db;
    return await db.insert(_dbName, weight.toMap());
  }

  Future<int> removeWeight(String id) async {
    Database db = await svc.db;
    return await db.delete(_dbName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWeight(Weight weight) async {
    Database db = await svc.db;
    return await db.update(_dbName, weight.toMap(),
        where: 'id = ?', whereArgs: [weight.id]);
  }
}
