import 'dart:collection';

import 'package:swole_experience/model/food_history.dart';

/**
 * Rationale behind map vs list: meal numbers might change to named meals
 */

class FoodMap {
  static HashMap<int, List<FoodHistory>> buildFoodMap(List<FoodHistory> foods) {
    HashMap<int, List<FoodHistory>> foodMap = HashMap();
    for (FoodHistory food in foods) {
      foodMap.update(food.mealNumber, (List<FoodHistory> meal) {
        meal.add(food);
        return meal;
      }, ifAbsent: () {
        return [food];
      });
    }
    return foodMap;
  }
}
