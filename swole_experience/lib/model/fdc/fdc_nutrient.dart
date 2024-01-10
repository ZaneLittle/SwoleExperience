import 'package:logger/logger.dart';

/// See: https://app.swaggerhub.com/apis/fdcnal/food-data_central_api/1.0.1#/FDC/postFoodsSearch
class FdcNutrient {
  static const int protein = 1003;
  static const int fat = 1004;
  static const int carb = 1005;

  FdcNutrient({
    required this.nutrientId,
    this.nutrientName,
    this.unitName,
    this.value,
  });

  final int nutrientId;
  final String? nutrientName;
  final String? unitName;
  final double? value;

  factory FdcNutrient.fromJson(Map<String, dynamic> json) {
    try {
      return FdcNutrient(
        nutrientId: json['nutrientId'],
        nutrientName: json['nutrientName'],
        unitName: json['unitName'],
        value: double.tryParse(json['value']?.toString() ?? ''),
      );
    } catch (e) {
      Logger().w('Failed to parse nutrient', error: e);
      return FdcNutrient(nutrientId: 0000);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nutrientId': nutrientId,
      'nutrientName': nutrientName,
      'unitName': unitName,
      'value': value,
    };
  }
}