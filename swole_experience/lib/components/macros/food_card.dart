import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/food_summary.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/macro_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/service/db/food_catalog_service.dart';

class FoodCard extends StatefulWidget {
  const FoodCard({super.key, required this.mealNum, required this.food, required this.addFood, required this.refresh, required this.isDeletable});

  final int mealNum;
  final Food food;
  final bool isDeletable;
  final Function addFood;
  final Function refresh;

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  double getHeight() => widget.food.brand == null ? 70 : 90;

  @override
  Widget build(BuildContext context) {
    Food food = widget.food;
    String amount = food.amount.toStringAsFixed(food.amount.truncateToDouble() == food.amount ? 0 : 2);
    return Card(
        key: Key('${food.id}-card'),
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FoodSummary(
                          addFood: widget.addFood,
                          food: food,
                          mealNum: widget.mealNum)));
            },
            onLongPress: widget.isDeletable ? () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Food?'),
                    content: Text('Are you sure you want to delete ${food.name} from your catalog?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          FoodCatalogService.svc.delete(food.id);
                          widget.refresh();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } : null,
            key: Key('${food.id}-gesture'),
            child: Card(
                color: CommonStyles.cardBackground,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: getHeight(),
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(food.name, // TODO: Set a max width / overflow
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text('${food.calories.toStringAsFixed(1)} cal'),
                                    ]),
                            food.brand != null ? Row(
                              children: [
                                Text(food.brand!)
                              ]
                            ) : Container(),
                            Padding(padding: const EdgeInsets.only(top: 8), child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$amount ${food.unit.name}'),
                                Row(children: [
                                  Text('C: ${food.carbs.toStringAsFixed(1)}', style: const TextStyle(color: MacroStyles.carbColour)),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                          'P: ${food.protein.toStringAsFixed(1)}' , style: const TextStyle(color: MacroStyles.proteinColour))),
                                  Text('F: ${food.fat.toStringAsFixed(1)}' , style: const TextStyle(color: MacroStyles.fatColour)),
                                ]),
                              ],
                            ))
                          ],
                        ))))));
  }
}