import 'package:swole_experience/model/unit.dart';

import 'food.dart';

class FoodHistory extends Food {
  FoodHistory({
    required id,
    fdcId,
    barcode,
    lastUpdated,
    required name,
    brand,
    required calories,
    required protein,
    required fat,
    required carbs,

    required this.amount,
    required this.unit,
    required this.foodId,
    required this.mealNumber,
    required this.date,
    this.exactTime, // TODO: This may be implemented in the future to display the food on a calendar view. For now it will sit empty in the model.
  }) : super(
    id: id,
    fdcId: fdcId,
    barcode: barcode,
    lastUpdated: lastUpdated,
    name: name,
    brand: brand,
    calories: calories,
    protein: protein,
    fat: fat,
    carbs: carbs,
  );

  final String foodId;
  final int mealNumber;
  final DateTime date;
  final DateTime? exactTime;
  final double amount;
  final Unit unit;

  FoodHistory.fromMap(Map<String, dynamic> map)
      : foodId = map['foodId'] as String,
        mealNumber = map['mealNumber'] as int,
        date = DateTime.parse(map['date'] as String),
        exactTime = DateTime.tryParse(map['exactTime'] as String),
        amount = double.parse(map['amount']),
        unit = unitFromString(map['unit']) ?? Unit.g,
        super.fromMap(map);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> fMap = super.toMap();
    fMap.addAll({
      'mealNumber': mealNumber,
      'date': date,
      'exactTime': exactTime,
    });
    return fMap;
  }
}