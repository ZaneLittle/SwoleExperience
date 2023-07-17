import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/food_catalog.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food_history.dart';

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

  double getHeight() {
    if (widget.foods.isEmpty) {
      return 64;
    }
    return 64 + ((widget.foods.length) * 92);
  }

  void addCallback(FoodHistory food) {
    // TODO: Add to meal
  }

  void add() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FoodCatalog(
                callback: addCallback, mealNum: widget.mealNum))).then(rebuild);
  }

  Widget buildFoodItem(FoodHistory food) {
    return Card(
        key: Key('${food.id}-card'),
        child: Card(
            color: CommonStyles.cardBackground,
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 72,
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(food.name,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                  Text('${food.amount} ${food.unit.name}'),
                                  Text('cal: ${food.calories.toString()}'),
                                ])),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('carbs: ${food.carbs.toString()}'),
                            Text('protein: ${food.protein.toString()}'),
                            Text('fat: ${food.fat.toString()}'),
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

    // TODO: dynamic sizing based off number of meals and number of foods in a meal?
    return SizedBox(
        height: getHeight() + 60,
        child: ExpansionTile(
            key: widget.key,
            title: Text('Meal ${widget.mealNum}'),
            initiallyExpanded: expanded,
            children: [
              SizedBox(
                  height: getHeight(),
                  child: ListView(
                    controller: _scrollController,
                    children: meal,
                  ))
            ]));
  }
}
