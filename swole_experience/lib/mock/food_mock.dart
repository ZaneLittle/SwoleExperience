import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/unit.dart';

final List<Food> foodMock = [
  Food(
    id: '123',
    name: 'Steak',
    calories: 250,
    protein: 30,
    carbs: 0,
    fat: 20,
    amount: 100.0,
    unit: Unit.g,
    lastUpdated: DateTime.now(),
  ),
  Food(
    id: '1234',
    name: 'Potatoes',
    brand: 'Chiffon',
    calories: 250,
    protein: 30,
    carbs: 0,
    fat: 20,
    amount: 100.0,
    unit: Unit.g,
    lastUpdated: DateTime.now(),
  ),
  Food(
    id: '12345',
    name: 'Salad',
    calories: 250,
    protein: 30,
    carbs: 0,
    fat: 20,
    amount: 100.0,
    unit: Unit.g,
    lastUpdated: DateTime.now(),
  ),
];
