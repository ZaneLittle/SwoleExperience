import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:swole_experience/service/preference_service.dart';
import 'package:swole_experience/constants/weight_constant.dart';
import 'package:swole_experience/model/weight.dart';
import 'package:swole_experience/model/preference.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/constants/preference_constants.dart';

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

    String? startDateStr = startDate != null
        ? Converter().roundToNextDay(startDate).toString()
        : null;

    var weights = startDate != null
        ? await db.query(
            _dbName,
            orderBy: 'dateTime DESC',
            where: '"dateTime" >= ? AND "dateTime" <= ?',
            whereArgs: [dateBound, startDateStr],
          )
        : await db.query(
            _dbName,
            orderBy: 'dateTime DESC',
            where: '"dateTime" >= ?',
            whereArgs: [dateBound],
          );

    List<Weight> res = [];
    // TODO: Refector to only get preference once - rn its done each iteration which is big dumb
    for (Map<String, dynamic> w in weights) {
      res.add(await _convertWeightToPreferredUnit(Weight.fromMap(w)));
    }

    return res;
  }

  Future<int> addWeight(Weight weight) async {
    Database db = await svc.db;

    Weight weightInPounds = await _convertWeightToPounds(weight);

    return await db.insert(_dbName, weightInPounds.toMap());
  }

  Future<int> removeWeight(String id) async {
    Database db = await svc.db;
    return await db.delete(_dbName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWeight(Weight weight) async {
    Database db = await svc.db;

    Weight weightInPounds = await _convertWeightToPounds(weight);

    return await db.update(_dbName, weightInPounds.toMap(),
        where: 'id = ?', whereArgs: [weight.id]);
  }

  ///                               Helpers                                 ///

  /// Returns the appropriate multiplier to pounds based on the user's preferred weight
  /// /// TODO: refactor this and the duplicate in avg svc into utils file
  Future<double> _getMultiplier() async {
    List<Preference> weightPref =
        await PreferenceService.svc.getPreference(PreferenceConstant.weightUnitKey);
    return (weightPref.isNotEmpty) &&
            weightPref.first.value == WeightConstant.kilograms
        ? 2.205
        : (weightPref.isNotEmpty) &&
                weightPref.first.value == WeightConstant.stone
            ? 14
            : 1;
  }

  /// Converts a weight record to pounds based on the user's preference
  Future<Weight> _convertWeightToPounds(Weight weight) async {
    double multiplier = await _getMultiplier();
    return Weight(
        id: weight.id,
        dateTime: weight.dateTime,
        weight: weight.weight * multiplier);
  }

  /// Converts a weight in pounds to the user's preferred unit
  Future<Weight> _convertWeightToPreferredUnit(Weight weight) async {
    double multiplier = await _getMultiplier();
    return Weight(
        id: weight.id,
        dateTime: weight.dateTime,
        weight: weight.weight / multiplier);
  }
}
