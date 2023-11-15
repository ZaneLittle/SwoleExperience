import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/food_catalog_search_results.dart';
import 'package:swole_experience/constants/common_styles.dart';

class FoodCatalog extends StatefulWidget {
  const FoodCatalog({Key? key, required this.addFood, required this.mealNum})
      : super(key: key);

  final int mealNum;
  final Function addFood;

  @override
  State<FoodCatalog> createState() => _FoodCatalogState();
}

class _FoodCatalogState extends State<FoodCatalog> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _query = query);
    });
  }

  OutlineInputBorder borderStyle = OutlineInputBorder(
    borderSide: const BorderSide(width: 3, color: CommonStyles.primaryColour),
    borderRadius: BorderRadius.circular(15),
  );

  Widget buildSearchBar() {
    return SizedBox(
        height: 64,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: TextFormField(
              controller: _queryController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search...",
                contentPadding: const EdgeInsets.only(left: 13),
                border: borderStyle,
                focusedBorder: borderStyle,
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
          // actions: [
          //   IconButton(
          //       icon: const Icon(Icons.add_circle_outline),
          //       iconSize: 32,
          //       onPressed: () {
          //         // TODO: Create new food item
          //       })
          // ],
          title: const Text('Add food'),
        ),
        body: Column(children: [
          buildSearchBar(),
          SizedBox(
              height: MediaQuery.of(context).size.height - 169.5,
              child: FoodCatalogSearchResults(
                  // TODO: This is overflowing when keyboard is open
                  addFood: widget.addFood,
                  mealNum: widget.mealNum,
                  query: _query))
        ]));
  }
}
