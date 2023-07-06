import 'package:flutter/material.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food_history.dart';

class FoodCatalog extends StatefulWidget {
  const FoodCatalog({Key? key})
      : super(key: key);

  @override
  State<FoodCatalog> createState() => _FoodCatalogState();
}

class _FoodCatalogState extends State<FoodCatalog> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
