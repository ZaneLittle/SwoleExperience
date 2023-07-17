import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/macros/food_catalog.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/food_history.dart';
import 'package:swole_experience/model/unit.dart';
import 'package:swole_experience/util/validator.dart';

class FoodSummary extends StatefulWidget {
  const FoodSummary(
      {Key? key,
      required this.mealNum,
      required this.food,
      required this.callback})
      : super(key: key);

  final int mealNum;
  final Food food;
  final Function callback;

  @override
  State<FoodSummary> createState() => _FoodSummaryState();
}

class _FoodSummaryState extends State<FoodSummary> {
  final TextEditingController _inputController = TextEditingController();
  bool expanded = true;
  double? amount;
  Unit? unit;

  double convert(double foodData) {
    if (amount == null) {
      return foodData;
    } else if (unit == widget.food.unit) {
      return (foodData / widget.food.amount) * amount!;
    } else {
      return 0.0; // TODO: Convert
    }
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
                icon: const Icon(Icons.edit),
                iconSize: 32,
                onPressed: () {}) // TODO: edit
          ],
          title: const Text(''),
        ),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(24),
              child: Text(widget.food.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold))),
          // TODO: Line separator?
          widget.food.brand != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(widget.food.brand!))
              : Container(),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Calories'),
                    Text(convert(widget.food.calories).toStringAsFixed(1))
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Protein'),
                    Text(convert(widget.food.protein).toStringAsFixed(1))
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Carbs'),
                    Text(convert(widget.food.carbs).toStringAsFixed(1))
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fat'),
                    Text(convert(widget.food.fat).toStringAsFixed(1))
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                    width: 72,
                    child: TextFormField(
                      controller: _inputController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (String? value) {
                        return Validator.doubleValidator(value);
                      },
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                        width: 64,
                        child: DropdownButton(
                          value: unit ?? widget.food.unit,
                          items: Unit.values
                              .map((unitConst) => DropdownMenuItem(
                                  child: Text(unitConst.name),
                                  value: unitConst))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => unit = value as Unit),
                        ))),
                ElevatedButton(onPressed: () {}, child: const Text('Add'))
              ])),
        ]));
  }
}
