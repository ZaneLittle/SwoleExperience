import 'package:flutter/material.dart';
import 'package:swole_experience/constants/MacroStyles.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/unit.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/util/validator.dart';

class FoodSummary extends StatefulWidget {
  const FoodSummary(
      {Key? key,
      required this.mealNum,
      required this.food,
      required this.addFood})
      : super(key: key);

  final int mealNum;
  final Food food;
  final Function addFood;

  @override
  State<FoodSummary> createState() => _FoodSummaryState();
}

class _FoodSummaryState extends State<FoodSummary> {
  final TextEditingController _inputController = TextEditingController();
  bool expanded = true;
  double? amount;
  Unit unit = Unit.g;

  @override
  void initState() {
    super.initState();
    amount = widget.food.amount;
    unit = widget.food.unit;
    _inputController.text =
        amount?.toStringAsFixed(amount?.truncateToDouble() == amount ? 0 : 1) ??
            '';
  }

  double convert(double foodData) {
    if (amount == null) {
      return foodData;
    } else {
      double convAmt = Converter.convertUnit(amount!, widget.food.unit, unit);
      return (foodData / widget.food.amount) * convAmt;
    }
  }

  void setAmount(String value) {
    double? newAmt = double.tryParse(value);
    setState(() => amount = newAmt ?? 0);
  }

  void addItem() {
    widget.addFood(widget.food.toFoodHistory(
        mealNumber: widget.mealNum,
        historyAmt: amount,
        historyCal: convert(widget.food.calories),
        historyCarb: convert(widget.food.carbs),
        historyPro: convert(widget.food.protein),
        historyFat: convert(widget.food.fat),
        historyUnit: unit));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget buildInputRow() {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 72,
              height: 38,
              child: TextFormField(
                controller: _inputController,
                onChanged: setAmount,
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
                  height: 50,
                  child: DropdownButton(
                    value: unit,
                    items: Unit.values
                        .map((unitConst) => DropdownMenuItem(
                            child: Text(unitConst.name), value: unitConst))
                        .toList(),
                    onChanged: (value) => setState(() => unit = value as Unit),
                  ))),
          ElevatedButton(
              onPressed: addItem,
              child: const Text('Add'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      CommonStyles.primaryColour)))
        ]));
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
                    Text(
                      convert(widget.food.protein).toStringAsFixed(1),
                      style: const TextStyle(color: MacroStyles.proteinColour),
                    ),
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Carbs'),
                    Text(
                      convert(widget.food.carbs).toStringAsFixed(1),
                      style: const TextStyle(color: MacroStyles.carbColour),
                    )
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fat'),
                    Text(convert(widget.food.fat).toStringAsFixed(1),
                        style: const TextStyle(color: MacroStyles.fatColour))
                  ])),
          buildInputRow(),
        ]));
  }
}
