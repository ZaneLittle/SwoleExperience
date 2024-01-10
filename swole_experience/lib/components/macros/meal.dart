import 'package:flutter/material.dart';
import 'package:swole_experience/components/alert_snack_bar.dart';
import 'package:swole_experience/components/macros/food_catalog.dart';
import 'package:swole_experience/constants/macro_styles.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/food_history.dart';
import 'package:swole_experience/service/db/food_catalog_service.dart';
import 'package:swole_experience/service/db/food_history_service.dart';

class Meal extends StatefulWidget {
  const Meal({super.key, required this.mealNum, required this.foods});

  final int mealNum;
  final List<FoodHistory> foods;

  @override
  State<Meal> createState() => _MealState();
}

class _MealState extends State<Meal> {
  final ScrollController _scrollController = ScrollController();
  bool expanded = true;
  List<FoodHistory>? foods;

  @override
  void initState() {
    super.initState();
    foods = widget.foods;
  }

  double getHeight() {
    if (foods!.isEmpty) {
      return 64;
    }
    return 64 + ((foods!.length) * 92);
  }

  void addCallback(FoodHistory food) async {
    String? historyError = await FoodHistoryService.svc.create(food);
    if (historyError != null) {
      // TODO: rewrite to not use BuildContext
      AlertSnackBar(
        message: historyError,
        state: SnackBarState.failure
      ).alert(context);
    } else {
      String? catalogError = await FoodCatalogService.svc.createOrUpdate(
          Food.fromFoodHistory(food));
      if (catalogError != null) {
        // TODO: rewrite to not use BuildContext
        AlertSnackBar(
            message: catalogError,
            state: SnackBarState.warning
        ).alert(context);
      }
      setState(() => foods!.add(food));
    }
  }

  void add() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FoodCatalog(
                addFood: addCallback, mealNum: widget.mealNum)));
  }

  Widget buildFoodItem(FoodHistory food) {
    return Card(
        key: Key('${food.id}-card'),
        // TODO: Make dismissable : left for delete and right for update
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
                            Text('carbs: ${food.carbs.toStringAsFixed(1)}', style: const TextStyle(color: MacroStyles.carbColour)),
                            Text('protein: ${food.protein.toStringAsFixed(1)}', style: const TextStyle(color: MacroStyles.proteinColour)),
                            Text('fat: ${food.fat.toStringAsFixed(1)}', style: const TextStyle(color: MacroStyles.fatColour)),
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
        child: const Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
    return foods!.map((food) {
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
