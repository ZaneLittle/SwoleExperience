import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/response/response.dart';

class FoodResponse extends Response<Food> {
  FoodResponse({
    required super.data,
    required super.total,
    super.error,
  });
}