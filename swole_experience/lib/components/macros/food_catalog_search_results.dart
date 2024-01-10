import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/food_card.dart';
import 'package:swole_experience/components/macros/food_summary.dart';
import 'package:swole_experience/constants/macro_styles.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/response/food_response.dart';
import 'package:swole_experience/service/db/food_catalog_service.dart';
import 'package:swole_experience/service/rest/fdc.dart';

class FoodCatalogSearchResults extends StatefulWidget {
  const FoodCatalogSearchResults(
      {super.key,
      required this.addFood,
      required this.mealNum,
      required this.query});

  final int mealNum;
  final Function addFood;
  final String query;

  @override
  State<FoodCatalogSearchResults> createState() =>
      _FoodCatalogSearchResultsState();
}

class _FoodCatalogSearchResultsState extends State<FoodCatalogSearchResults> {
  final ScrollController _scrollController = ScrollController();
  final FdcService fdc = FdcService();

  void refresh() => setState(() {});

  List<Widget> buildFoodCards(FoodResponse fdcFoods, List<Food> userFoods) {
    if (fdcFoods.data.isEmpty && fdcFoods.error == null && userFoods.isEmpty) {
      return [buildNoResults()];
    }

    List<Widget> userFoodList = [];
    userFoodList.add(const Center(
        child: Text('My Food Results',
            style: TextStyle(color: CommonStyles.primaryColour))));
    userFoodList.addAll(userFoods
        .map((food) => FoodCard(
            mealNum: widget.mealNum, food: food, addFood: widget.addFood, refresh: refresh, isDeletable: true))
        .toList());

    List<Widget> fdcFoodList = [];
    fdcFoodList.add(const Center(
        child: Text('FDC Results',
            style: TextStyle(color: CommonStyles.primaryColour))));
    fdcFoodList.addAll(fdcFoods.data
        .map((food) => FoodCard(
            mealNum: widget.mealNum, food: food, addFood: widget.addFood, refresh: refresh, isDeletable: false))
        .toList());
    if (fdcFoods.error != null) {
      fdcFoodList.add(Center(
          child: Text(
              'There was a problem retrieving results from the FDC: \n${fdcFoods.error?.message}',
              style: const TextStyle(fontStyle: FontStyle.italic))));
    }

    if (userFoods.isEmpty) {
      return fdcFoodList;
    } else if (fdcFoods.data.isEmpty && fdcFoods.error == null) {
      return userFoodList;
    } else {
      userFoodList.addAll(fdcFoodList);
      return userFoodList;
    }
  }

  Widget buildNoResults() {
    return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No Results Found')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: Future.wait([
          fdc.search(widget.query),
          FoodCatalogService.svc.search(query: widget.query),
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading...'));
          } else {
            List<Widget> searchResults = [];
            if (snapshot.data == null ||
                snapshot.data!.isEmpty ||
                (snapshot.data![0].data.isEmpty && snapshot.data![1].isEmpty)) {
              searchResults.add(const Center(child: Text('No Results Found')));
            } else {
              searchResults
                  .addAll(buildFoodCards(snapshot.data![0], snapshot.data![1]));
            }

            return ListView(
                controller: _scrollController, children: searchResults);
          }
        });
  }
}
