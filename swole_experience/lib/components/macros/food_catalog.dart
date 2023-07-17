import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/food_summary.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/service/db/food_catalog_service.dart';

class FoodCatalog extends StatefulWidget {
  const FoodCatalog({Key? key, required this.callback, required this.mealNum}) : super(key: key);

  final int mealNum;
  final Function callback;

  @override
  State<FoodCatalog> createState() => _FoodCatalogState();
}

class _FoodCatalogState extends State<FoodCatalog> {
  final ScrollController _scrollController = ScrollController();
  String query = '';

  List<Widget> buildFoodCards(List<Food> foods) {
    return foods.map((food) {
      return Card(
          key: Key('${food.id}-card'),
          child: Dismissible(
            onDismissed: (DismissDirection direction) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FoodSummary(callback: widget.callback, food: food, mealNum: widget.mealNum)));
            },
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
                                    Text(food.brand ?? ''),
                                    Text(
                                        'per ${food.amount} ${food.unit.name}'),
                                  ])),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('cal: ${food.calories.toString()}'),
                              Text('carbs: ${food.carbs.toString()}'),
                              Text('protein: ${food.protein.toString()}'),
                              Text('fat: ${food.fat.toString()}'),
                            ],
                          )
                        ],
                      ))))));
    }).toList();
  }

  Widget buildNoResults() {
    return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No Results Found')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CommonStyles.primaryDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 32,
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
                onPressed: () {
                  // TODO: Create new food item
                })
          ],
          title: const Text('Add food'),
        ),
        body: FutureBuilder<List<List<dynamic>>>(
            future: Future.wait([FoodCatalogService.svc.search()]),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              } else {

                List<Widget> searchResults = [];
                    if (snapshot.data != null &&
                        snapshot.data!.isNotEmpty &&
                        snapshot.data?[0].isNotEmpty)
                    { searchResults.addAll(buildFoodCards(snapshot.data![0]));} else {
                       searchResults.add(const Text('No Results Found'));
                  }

                // List<Widget> searchResults = [buildNoResults()];

                return SizedBox(
                    child: ListView(
                        controller: _scrollController,
                        children: searchResults));
              }
            }));
  }
}
