import 'package:swole_experience/model/food_history.dart';
import 'package:swole_experience/model/unit.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:uuid/uuid.dart';

class Food {
  Food({
    required this.id,
    this.fdcId,
    this.barcode,
    required this.lastUpdated,
    required this.name,
    this.brand,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.amount,
    required this.unit,
    this.customUnit,
    this.gramConversion,
  });

  final String id;
  final int? fdcId;
  final String? barcode;
  DateTime lastUpdated;
  final String name;
  final String? brand;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double amount;
  final Unit unit;
  final String? customUnit;
  final double? gramConversion;

  Food.fromMap(Map<String, dynamic> map)
      :  id = map['id'] as String,
      fdcId = int.tryParse(map['fcdId'] as String? ?? ''),
      barcode = map['barcode'] as String?,
      lastUpdated = DateTime.parse(map['lastUpdated'] as String),
      name = map['name'] as String,
      brand = map['brand'] as String?,
      calories = map['calories'],
      protein = map['protein'],
      fat = map['fat'],
      carbs = map['carbs'],
      amount = map['amount'],
      unit = parseUnit(map['unit']),
      customUnit = parseUnit(map['unit']) == Unit.custom ? map['customUnit'] as String? : null,
      gramConversion = map['gramConversion'] as double?;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fdcId': fdcId,
      'barcode': barcode,
      'lastUpdated': lastUpdated.toString(),
      'name': name,
      'brand': brand,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'amount': amount,
      'unit': unit.toString(),
      'customUnit': customUnit,
      'gramConversion': gramConversion,
    };
  }

  FoodHistory toFoodHistory({
      required int mealNumber,
      double? historyAmt,
      double? historyCal,
      double? historyCarb,
      double? historyPro,
      double? historyFat,
      String? historyId,
      Unit? historyUnit,
      String? historyCustomUnit,
      double? historyGramConversion,
      DateTime? date,
      DateTime? exactTime,
      DateTime? histLastUpdated}) {
    return FoodHistory(
      id: historyId ?? const Uuid().v4(),
      fdcId: fdcId,
      foodId: id,
      name: name,
      brand: brand,
      calories: historyCal ?? calories,
      protein: historyPro ?? protein,
      fat: historyFat ?? fat,
      carbs: historyCarb ?? carbs,
      amount: historyAmt ?? amount,
      unit: historyUnit ?? unit,
      customUnit: historyCustomUnit ?? customUnit,
      gramConversion: historyGramConversion ?? gramConversion,
      mealNumber: mealNumber,
      date: date ?? Converter.truncateToDay(DateTime.now()),
      barcode: barcode,
      lastUpdated: histLastUpdated ?? DateTime.now(),
      exactTime: exactTime ?? DateTime.now(),
    );
  }

  Food.fromFoodHistory(FoodHistory foodHistory)
      : id = foodHistory.id,
        fdcId = foodHistory.fdcId,
        barcode = foodHistory.barcode,
        lastUpdated = foodHistory.lastUpdated,
        name = foodHistory.name,
        brand = foodHistory.brand,
        calories = foodHistory.calories,
        protein = foodHistory.protein,
        fat = foodHistory.fat,
        carbs = foodHistory.carbs,
        amount = foodHistory.amount,
        unit = foodHistory.unit,
        customUnit = foodHistory.customUnit,
        gramConversion = foodHistory.gramConversion;
}
