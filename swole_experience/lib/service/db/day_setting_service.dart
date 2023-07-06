import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/model/day_setting.dart';

/// DaySettingService stores a key value string pair with a last updated date
/// DaySetting = {
///   INTEGER dayNumber = the number of the day (defines order and is the default name)
///   TEXT name         = the name override for the day
///   TEXT lastUpdated  = String representation of the DateTime the object was last updated
/// }
class DaySettingService {
  static const String _dbName = 'daySettings';

  DaySettingService._privateConstructor();

  static final DaySettingService svc = DaySettingService._privateConstructor();

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
          dayNumber INTEGER PRIMARY KEY,
          name TEXT,
          lastUpdated TEXT
        )
    ''');
  }

  /// Return list of all daySettings
  Future<List<DaySetting>> getDaySettings() async {
    Database db = await svc.db;

    var daySettings = await db.query(_dbName);

    return daySettings.map((daySetting) => DaySetting.fromMap(daySetting)).toList();
  }

  /// Creates or updates a given daySetting
  Future<int> setDaySetting(DaySetting daySetting) async {
    Database db = await svc.db;

    int res = await db.update(_dbName, daySetting.toMap(),
        where: 'dayNumber = ?', whereArgs: [daySetting.dayNumber]);
    if (res == 0) {
      return await db.insert(_dbName, daySetting.toMap());
    }
    return res;
  }


}
