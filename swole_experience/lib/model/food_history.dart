import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/util/converter.dart';

/// Model:
///    @id: unique ID of this history item
///    @fdcId: ID from the FDC API
///    @foodId: ID of the parent Food item
///
///    @name: Name of the food
///    @brand: Brand of the food
///
///    @calories, @protein, @fat, @carbs: macro information
///    @amount: value in the @unit (or @customUnitName if present) that was consumed
///    @customUnitName: A string value representing a custom unit type (ex per 'cookie') the user has entered
///    @gramConversion: The multiplier used to convert 1 @customUnit name to 1 gram
///    @date: date (without time information) the item was added
///       NOTE: the reason we store date separate from exactTime is to make querying easier and more efficient
///
///    @barcode: barcode from scanner for product -- TODO: V2
///    @lastUpdated: DateTime when the item was update -- TODO: Not used but might be useful for display down the line
///    @exactTime: Exact time the item was added -- TODO: V2 or V3 - this could be used to display in a calendar view

class FoodHistory extends Food {
  FoodHistory({
    required super.id,
    super.fdcId,
    required this.foodId,

    required super.name,
    super.brand,

    required super.calories,
    required super.protein,
    required super.fat,
    required super.carbs,
    required super.amount,
    required super.unit,
    super.customUnit,
    super.gramConversion,
    required this.mealNumber,
    required this.date,

    super.barcode,
    required super.lastUpdated,
    this.exactTime,
  });

  final String foodId;
  final int mealNumber;
  final DateTime date;
  final DateTime? exactTime;

  FoodHistory.fromMap(super.map)
      : foodId = map['foodId'] as String,
        mealNumber = map['mealNumber'] as int,
        date = DateTime.parse(map['date'] as String),
        exactTime = DateTime.tryParse(map['exactTime'] as String? ?? ''),
        super.fromMap();

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