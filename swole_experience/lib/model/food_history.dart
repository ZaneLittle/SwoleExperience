import 'package:swole_experience/model/unit.dart';
import 'package:swole_experience/util/converter.dart';

import 'food.dart';

/// Model:
///    @id: unique ID of this history item
///    @fdcId: ID from the FDC API
///    @foodId: ID of the parent Food item
///
///    @name: Name of the food
///    @brand: Brand of the food
///
///    @calories, @protein, @fat, @carbs: macro information
///    @amount: value in the @unit that was consumed
///    @date: date (without time information) the item was added
///       NOTE: the reason we store date separate from exactTime is to make querying easier and more efficient
///
///    @barcode: barcode from scanner for product -- TODO: V2
///    @lastUpdated: DateTime when the item was update -- TODO: Not used but might be useful for display down the line
///    @exactTime: Exact time the item was added -- TODO: V2 or V3 - this could be used to display in a calendar view

class FoodHistory extends Food {
  FoodHistory({
    required String id,
    int? fdcId,
    required this.foodId,

    required String name,
    String? brand,

    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required double amount,
    required Unit unit,
    required this.mealNumber,
    required this.date,

    String? barcode,
    required DateTime lastUpdated,
    this.exactTime,
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
    amount: amount,
    unit: unit,
  );

  final String foodId;
  final int mealNumber;
  final DateTime date;
  final DateTime? exactTime;

  FoodHistory.fromMap(Map<String, dynamic> map)
      : foodId = map['foodId'] as String,
        mealNumber = map['mealNumber'] as int,
        date = DateTime.parse(map['date'] as String),
        exactTime = DateTime.tryParse(map['exactTime'] as String? ?? ''),
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> fMap = super.toMap();
    fMap.addAll({
      'foodId': foodId,
      'mealNumber': mealNumber,
      'date': Converter.truncateToDay(date).toString(),
      'exactTime': exactTime.toString(),
    });
    return fMap;
  }
}