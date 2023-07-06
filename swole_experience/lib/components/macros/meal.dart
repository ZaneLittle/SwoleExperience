import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food_history.dart';

import 'food-catalog.dart';

class Meal extends StatefulWidget {
  const Meal({Key? key, required this.mealNum, required this.foods})
      : super(key: key);

  final int mealNum;
  final List<FoodHistory> foods;

  @override
  State<Meal> createState() => _MealState();
}

class _MealState extends State<Meal> {
  final ScrollController _scrollController = ScrollController();
  bool expanded = true;

  FutureOr rebuild(dynamic val) {
    setState(() {});
  }

  void add() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const FoodCatalog()))
        .then(rebuild);
  }

  Widget buildFoodItem(FoodHistory food) {
    return Card(
        key: Key('${food.id}-card'),
        child: Card(
            color: CommonStyles.cardBackground,
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 100, // TODO: Size this properly
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(food.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text('${food.amount}${food.unit}'),
                              Text(food.calories.toString()),
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(food.carbs.toString()),
                            Text(food.protein.toString()),
                            Text(food.fat.toString()),
                          ],
                        )
                      ],
                    )))));
  }

  Widget buildAdd() {
    return TextButton(
        onPressed: () {
          add();
        },
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle, color: CommonStyles.primaryColour),
                Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      'Add Food',
                      style: TextStyle(color: CommonStyles.primaryColour),
                    ))
              ],
            )));
  }

  List<Widget> buildMeal() {
    return widget.foods.map((food) {
      return buildFoodItem(food);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> meal = buildMeal();
    meal.add(buildAdd());

    return ExpansionTile(
        key: widget.key,
        title: Text('Meal ${widget.mealNum}'),
        initiallyExpanded: expanded,
        children: [
          ListView(
            controller: _scrollController,
            children: meal,
          )
        ]);
  }
}
