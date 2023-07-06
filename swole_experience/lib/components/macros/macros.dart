import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/meal.dart';
import 'package:swole_experience/components/preferences/settings_button.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/preference_constants.dart';
import 'package:swole_experience/model/food_history.dart';
import 'package:swole_experience/service/db/food_history_service.dart';
import 'package:swole_experience/service/db/preference_service.dart';
import 'package:swole_experience/util/food_map.dart';

class Macros extends StatefulWidget {
  const Macros({Key? key}) : super(key: key);

  @override
  State<Macros> createState() => _MacrosState();
}

class _MacrosState extends State<Macros> {
  final ScrollController _scrollController = ScrollController();
  String dayText = 'Today';
  int offset = 0;
  int mealsNum = PreferenceConstant.defaultNumMeals;

  FutureOr rebuild(dynamic value) {
    setState(() {});
  }

  void updateView(int offset) {
    setState(() {
      offset = offset;
    });
  }

  void setupDay() {
    switch (offset) {
      case 0:
        {
          dayText = "    Today    ";
        }
        break;
      case -1:
        {
          dayText = "Yesterday";
        }
        break;
      case 1:
        {
          dayText = "Tomorrow ";
        }
        break;
      default:
        {
          DateTime now = DateTime.now();
          dayText = '${now.year}-${now.month}-${now.day + offset}';
        }
        break;
    }
  }

  Widget buildDaySelect(AsyncSnapshot<List<List<dynamic>>> dataSnapshot) {
    return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 0),
                child: SettingsButton(rebuildCallback: rebuild)),
            IconButton(
                onPressed: () => updateView(-1),
                icon: const Icon(Icons.keyboard_arrow_left,
                    color: CommonStyles.primaryColour)),
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(dayText,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(
                onPressed: () => updateView(1),
                icon: const Icon(Icons.keyboard_arrow_right,
                    color: CommonStyles.primaryColour))
          ],
        ));
  }

  List<Widget> buildMeals(List<FoodHistory> foods) {
    Map<int, List<FoodHistory>> foodMap = FoodMap.buildFoodMap(foods);

    List<Widget> meals = [];
    for (int mealKey in foodMap.keys) {
      meals.add(Meal(mealNum: mealKey, foods: foodMap[mealKey] ?? []));
    }

    return meals;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day + offset);

    return FutureBuilder<List<List<dynamic>>>(
        future: Future.wait([
          FoodHistoryService.svc.get(date: date),
          PreferenceService.svc.getPreference(PreferenceConstant.numMeals)
        ]),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading...'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('Something Went Wrong.'));
          } else {
            if (snapshot.data!.length <= 2 || snapshot.data![1].isNotEmpty) {
              mealsNum = int.tryParse(snapshot.data![1][0]) ??
                  PreferenceConstant.defaultNumMeals;
            }

            return Expanded(
                child: Column(
              children: [
                buildDaySelect(snapshot),
                ListView(
                  controller: _scrollController,
                  children: buildMeals(snapshot.data![0] as List<FoodHistory>),
                )
              ],
            ));
          }
        });
  }
}
