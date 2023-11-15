import 'dart:math';

import 'package:swole_experience/model/food_history.dart';
import 'package:swole_experience/model/unit.dart';
import 'package:swole_experience/util/converter.dart';

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
  });

  final String id;
  final int? fdcId;
  final String? barcode;
  final DateTime lastUpdated;
  final String name;
  final String? brand;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double amount;
  final Unit unit;

  Food.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
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
        unit = unitFromString(map['unit']) ?? Unit.g;

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
      DateTime? date,
      DateTime? exactTime,
      DateTime? histLastUpdated}) {
    return FoodHistory(
      id: historyId ?? Random().nextInt(9999).toString(),
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
      mealNumber: mealNumber,
      date: date ?? Converter.truncateToDay(DateTime.now()),
      barcode: barcode,
      lastUpdated: histLastUpdated ?? DateTime.now(),
      exactTime: exactTime ?? DateTime.now(),
    );
  }
}
