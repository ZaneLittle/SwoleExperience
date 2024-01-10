import 'package:swole_experience/model/unit.dart';
import 'package:uuid/uuid.dart';

import 'package:swole_experience/model/fdc/fdc_nutrient.dart';
import 'package:swole_experience/model/food.dart';

/// See: https://app.swaggerhub.com/apis/fdcnal/food-data_central_api/1.0.1#/FDC/postFoodsSearch
class FdcSearchResult {
  FdcSearchResult({
    required this.fdcId,
    required this.description,
    this.foodNutrients,
    this.servingSizeUnit,
    this.servingSize,
    this.publishedDate,
    this.brandName,
    this.brandOwner,
    this.ingredients,
    this.additionalDescriptions,
  });

  final int fdcId;
  final String description;
  final List<FdcNutrient>? foodNutrients;
  final String? servingSizeUnit;
  final double? servingSize;
  final String? publishedDate;
  final String? brandName;
  final String? brandOwner;
  final String? ingredients;
  final String? additionalDescriptions;

  factory FdcSearchResult.fromJson(Map<String, dynamic> json) {
    List<FdcNutrient>? nutrients = (json['foodNutrients'] as List)
        .map((i) => FdcNutrient.fromJson(i))
        .toList();
    return FdcSearchResult(
      fdcId: json['fdcId'],
      description: json['description'],
      foodNutrients: nutrients,
      servingSizeUnit: json['servingSizeUnit'],
      servingSize: json['servingSize'],
      publishedDate: json['publishedDate'],
      brandName: json['brandName'],
      brandOwner: json['brandOwner'],
      ingredients: json['ingredients'],
      additionalDescriptions: json['additionalDescriptions'],
    );
  }

  Map<String, dynamic> toJson() => {
    'fdcId': fdcId,
    'description': description,
    'foodNutrients': foodNutrients?.map((i) => i.toJson()).toList(),
    'publishedDate': publishedDate,
    'servingSizeUnit': servingSizeUnit,
    'servingSize': servingSize,
    'brandName': brandName,
    'brandOwner': brandOwner,
    'ingredients': ingredients,
    'additionalDescriptions': additionalDescriptions,
  };

  Food toFood() {
    double protein = foodNutrients?.firstWhere((nutrient) => nutrient.nutrientId == FdcNutrient.protein).value ?? 0;
    double fat = foodNutrients?.firstWhere((nutrient) => nutrient.nutrientId == FdcNutrient.fat).value ?? 0;
    double carbs = foodNutrients?.firstWhere((nutrient) => nutrient.nutrientId == FdcNutrient.carb).value ?? 0;
    Unit? unit = parseUnit(servingSizeUnit);

    double cal = (protein * 4) + (carbs * 4) + (fat * 9);

    String? brand;
    if (brandName != null && brandOwner != null) {
      brand = '$brandName - $brandOwner';
    } else if (brandName != null) {
      brand = brandName;
    } else if (brandOwner != null) {
      brand = brandOwner;
    }

    return Food(
    id: const Uuid().v4(),
        fdcId: fdcId,
        name: description,
        brand: brand,
        protein: protein,
        carbs: carbs,
        fat: fat,
        calories: cal,
        amount: servingSize ?? 0,
        unit: unit, // TODO-enhancement: might look into changing this based off preference - something like a default unit and convert to that
        customUnit: unit == Unit.custom ? servingSizeUnit : null,
        lastUpdated: DateTime.tryParse(publishedDate ?? '') ?? DateTime.now()
    );
  }
}