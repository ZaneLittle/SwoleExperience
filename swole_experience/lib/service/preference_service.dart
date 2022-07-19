import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/model/preference.dart';

/// PreferenceService stores a key value string pair with a last updated date
/// Weight = {
///   TEXT preference  = the name of the preference - unique primary key
///   TEXT value       = the value of the preference
///   TEXT lastUpdated = String representation of the DateTime the preference was last updated
/// }
class PreferenceService {
  static const String _dbName = 'preferences';

  PreferenceService._privateConstructor();

  static final PreferenceService svc = PreferenceService._privateConstructor();

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
          preference TEXT PRIMARY KEY,
          value TEXT,
          lastUpdated TEXT
        )
    ''');
  }

  Future<Preference> getPreference(String preference) async {
    Database db = await svc.db;

    var preferences = await db.query(_dbName,
        orderBy: 'lastUpdated DESC',
        where: '"preference" = ?',
        whereArgs: [preference]);

    if (preferences.isEmpty) {
      logger.w('Did not find preference $preference, returning empty');
      return Preference(preference: preference);
    } else if (preferences.length > 1) {
      logger.w('Found multiple preferences for $preference, returning latest');
    }
    return Preference.fromMap(preferences.first);
  }

  Future<List<Preference>> getAllPreferences() async {
    Database db = await svc.db;

    var preferences = await db.query(
      _dbName,
      orderBy: 'lastUpdated DESC',
    );

    return preferences.isNotEmpty
        ? preferences.map((p) => Preference.fromMap(p)).toList()
        : [];
  }

  Future<int> addOrUpdatePreference(Preference preference) async {
    Database db = await svc.db;

    int res = await db.update(_dbName, preference.toMap(),
        where: 'preference = ?', whereArgs: [preference.preference]);
    if (res == 0) {
      return await db.insert(_dbName, preference.toMap());
    }
    return res;
  }
}
