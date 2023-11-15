import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/food_summary.dart';
import 'package:swole_experience/constants/MacroStyles.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/service/db/food_catalog_service.dart';

class FoodCatalogSearchResults extends StatefulWidget {
  const FoodCatalogSearchResults({Key? key, required this.addFood, required this.mealNum, required this.query})
      : super(key: key);

  final int mealNum;
  final Function addFood;
  final String query;

  @override
  State<FoodCatalogSearchResults> createState() => _FoodCatalogSearchResultsState();
}

class _FoodCatalogSearchResultsState extends State<FoodCatalogSearchResults> {
  final ScrollController _scrollController = ScrollController();

  List<Widget> buildFoodCards(List<Food> foods) {
    return foods.map((food) {
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
              key: Key('${food.id}-card'),
              child: Card(
                  color: CommonStyles.cardBackground,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 62,
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
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Text('${food.calories} cal'),
                                      ])),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  food.brand != null ? Text(
                                      '${food.brand}, ${food.amount} ${food.unit.name}')
                                      : Text('${food.amount} ${food.unit.name}'),
                                  Row(children: [
                                    Text('C: ${food.carbs.toString()}', style: const TextStyle(color: MacroStyles.carbColour)),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                            'P: ${food.protein.toString()}' , style: const TextStyle(color: MacroStyles.proteinColour))),
                                    Text('F: ${food.fat.toString()}' , style: const TextStyle(color: MacroStyles.fatColour)),
                                  ]),
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

    return FutureBuilder<List<List<dynamic>>>(
            future: Future.wait([FoodCatalogService.svc.search(query: widget.query)]),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              } else {
                List<Widget> searchResults = [];
                if (snapshot.data != null &&
                    snapshot.data!.isNotEmpty &&
                    snapshot.data?[0].isNotEmpty) {
                  searchResults.addAll(buildFoodCards(snapshot.data![0]));
                } else {
                  searchResults.add(const Text('No Results Found'));
                }

                return
                    ListView(
                          controller: _scrollController,
                          children: searchResults);
              }
            });
  }
}
