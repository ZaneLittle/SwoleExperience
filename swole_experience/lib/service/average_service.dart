import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swole_experience/constants/weight_constant.dart';

import 'package:swole_experience/model/average.dart';
import 'package:swole_experience/model/preference.dart';
import 'package:swole_experience/model/weight.dart';
import 'package:swole_experience/service/preference_service.dart';
import 'package:swole_experience/service/weight_service.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/constants/preference_constants.dart';

/// AverageService provides an interface to the `average` table.
/// This table stores rolling averages for unique days
/// Average: {
///   STRING date           = unique date the record is for (primary key)
///   FLOAT average         = average for the day
///   FLOAT threeDayAverage = average of the last 3 days of records
///   FLOAT sevenDayAverage = average of the last 7 days of records
/// }
///
/// Note: the rolling averages are calculated on the last X days worth records.
/// That is to say, if you skip 1 day, it will take the last 8 days, up to 60 days
/// Additionally, if there is not enough data to calculate the rolling average,
/// it will calculate a rolling average using as much data as it has
class AverageService {
  static const String _dbName = 'average';

  AverageService._privateConstructor();

  static final AverageService svc = AverageService._privateConstructor();

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
        dateTime TEXT PRIMARY KEY,
        average FLOAT,
        threeDayAverage FLOAT,
        sevenDayAverage FLOAT
        )
    ''');
  }

  /// Get a list of the averages for the past 60 days
  Future<List<Average>> getAverages({DateTime? startDate}) async {
    Database db = await svc.db;

    String dateBound =
        DateTime.now().subtract(const Duration(days: 60)).toString();

    String? startDateStr = startDate != null
        ? Converter.roundToNextDay(startDate).toString()
        : null;

    var averages = startDate != null
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

    List<Average> res = [];
    for (Map<String, dynamic> a in averages) {
      res.add(await _convertAverageToPreferredUnit(Average.fromMap(a)));
    }

    return res;
  }

  /// Updates the averages at the given string represented date
  /// If date cannot be parsed, it skips the operation.
  Future<int> calculateAverages(String date) async {
    Database db = await svc.db;

    DateTime? longDate = DateTime.tryParse(date);
    if (longDate == null) {
      return 0;
    }
    DateTime safeDate = Converter.truncateToDay(longDate);

    // Build the map
    List<Weight> weights =
        await WeightService.svc.getWeights(startDate: safeDate);
    Map<DateTime, List<double>> weightMap = {};
    for (Weight weight in weights) {
      DateTime currentDate = Converter.truncateToDay(weight.dateTime);
      weightMap[currentDate] == null
          ? weightMap[currentDate] = [weight.weight]
          : weightMap[currentDate]!.add(weight.weight);
    }
    List<double> threeDayAvgList = [];
    List<double> sevenDayAvgList = [];

    // Calculate the averages
    int threeDayStart = weightMap.length < 3 ? weightMap.length : 3;
    int sevenDayStart = weightMap.length < 7 ? weightMap.length : 7;

    int i = 0;
    for (List<double> value in weightMap.values) {
      double avg = value.reduce((a, b) => a + b) / value.length;
      (i < threeDayStart) ? threeDayAvgList.add(avg) : null;
      (i < sevenDayStart) ? sevenDayAvgList.add(avg) : null;

      if (i >= sevenDayStart) {
        break;
      }
      i++;
    }

    // Check if we have records for this day or we're recalculating an empty day
    if (weightMap[safeDate] != null) {
      Average average = Average(
        date: safeDate,
        average: double.parse((weightMap[safeDate]!.reduce((a, b) => a + b) /
                weightMap[safeDate]!.length)
            .toStringAsFixed(2)),
        threeDayAverage: double.parse(
            (threeDayAvgList.reduce((a, b) => a + b) / threeDayAvgList.length)
                .toStringAsFixed(2)),
        sevenDayAverage: double.parse(
            (sevenDayAvgList.reduce((a, b) => a + b) / sevenDayAvgList.length)
                .toStringAsFixed(2)),
      );

      int res = await db.update(_dbName, average.toMap(),
          where: 'dateTime = ?', whereArgs: [safeDate.toString()]);
      if (res == 0) {
        return await db.insert(_dbName, average.toMap());
      }
      return res;
    } else {
      // No records for the day, we should delete
      // Note that this is a safe delete, if the record doesn't exist, we wont fall over
      return await db.delete(_dbName,
          where: 'dateTime = ?', whereArgs: [safeDate.toString()]);
    }
  }

  ///                               Helpers                                 ///

  /// Returns the appropriate multiplier to pounds based on the user's preferred weight
  /// TODO: refactor this and the duplicate in weight svc into utils file
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

  /// Converts an average record to pounds based on the user's preference
  Future<Average> _convertAverageToPounds(Average average) async {
    double multiplier = await _getMultiplier();

    return Average(
        date: average.date,
        average: average.average * multiplier,
        threeDayAverage: average.threeDayAverage * multiplier,
        sevenDayAverage: average.sevenDayAverage * multiplier);
  }

  /// Converts an average record to pounds based on the user's preference
  Future<Average> _convertAverageToPreferredUnit(Average average) async {
    double multiplier = await _getMultiplier();

    return Average(
        date: average.date,
        average: average.average / multiplier,
        threeDayAverage: average.threeDayAverage / multiplier,
        sevenDayAverage: average.sevenDayAverage / multiplier);
  }
}
