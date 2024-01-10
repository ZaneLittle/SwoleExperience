import 'package:flutter/material.dart';
import 'package:swole_experience/constants/macro_styles.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/food.dart';
import 'package:swole_experience/model/unit.dart';
import 'package:swole_experience/service/db/food_catalog_service.dart';
import 'package:swole_experience/util/validator.dart';
import 'package:uuid/uuid.dart';

class FoodSummary extends StatefulWidget {
  const FoodSummary(
      {super.key,
        this.food,
        required this.callback});

  final Food? food;
  final Function callback;

  @override
  State<FoodSummary> createState() => _FoodSummaryState();
}

class _FoodSummaryState extends State<FoodSummary> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _calController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _customUnitController = TextEditingController();
  final TextEditingController _altUnitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.food?.name ?? '';
    _brandController.text = widget.food?.brand ?? '';
    _calController.text = widget.food?.calories.toString()  ?? '';
    _carbController.text = widget.food?.carbs.toString()  ?? '';
    _fatController.text = widget.food?.fat.toString()  ?? '';
    _proteinController.text = widget.food?.protein.toString()  ?? '';
    _amountController.text = widget.food?.amount.toString()  ?? '';
    _unitController.text = widget.food?.unit.toString()  ?? '';
    _customUnitController.text = widget.food?.customUnit ?? '';
  }

  // TODO: validate
  void submit() {
    Unit unit = parseUnit(_unitController.text);
    Food food = Food(
      id: widget.food?.id ?? const Uuid().v4(),
      fdcId: widget.food?.fdcId,
      barcode: widget.food?.barcode, // TODO: how do we scan barcodes
      lastUpdated: DateTime.now(),
      name: _nameController.text,
      brand: _brandController.text.isNotEmpty ? _brandController.text : null,
      calories: double.tryParse(_calController.text) ?? 0,
      carbs: double.tryParse(_carbController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      amount: double.tryParse(_amountController.text) ?? 0,
      unit: unit,
      customUnit: unit == Unit.custom ? _customUnitController.text : null,
      gramConversion: 0 // TODO
    );
    FoodCatalogService.svc.createOrUpdate(food);
    Navigator.pop(context);
  }

  // Widget buildInputRow() {
  //   return Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //         SizedBox(
  //             width: 72,
  //             height: 38,
  //             child: TextFormField(
  //               controller: _inputController,
  //               onChanged: setAmount,
  //               keyboardType:
  //               const TextInputType.numberWithOptions(decimal: true),
  //               validator: (String? value) {
  //                 return Validator.doubleValidator(value);
  //               },
  //             )),
  //         Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 24),
  //             child: SizedBox(
  //                 width: 64,
  //                 height: 50,
  //                 child: DropdownButton(
  //                   value: unit,
  //                   items: Unit.values
  //                       .map((unitConst) => DropdownMenuItem(
  //                       value: unitConst,
  //                       child: Text(unitConst.name)))
  //                       .toList(),
  //                   onChanged: (value) => setState(() => unit = value as Unit),
  //                 ))),
  //         ElevatedButton(
  //             onPressed: addItem,
  //             style: ButtonStyle(
  //                 backgroundColor: MaterialStateProperty.all<Color>(
  //                     CommonStyles.primaryColour)),
  //             child: const Text('Add'))
  //       ]));
  // }

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
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Name'),
                    TextFormField(controller: _nameController, validator: Validator.stringValidator),
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Brand'),
                    TextFormField(controller: _brandController, validator: Validator.stringValidator),
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Calories'),
                    TextFormField(controller: _calController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: Validator.doubleValidator,),
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Protein', style: TextStyle(color: MacroStyles.proteinColour)),
                    TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: Validator.doubleValidator,
                    ),
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Carbs', style: TextStyle(color: MacroStyles.carbColour)),
                    TextFormField(
                      controller: _carbController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validator.doubleValidator
    ),
                  ])),
          Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fat', style: TextStyle(color: MacroStyles.fatColour)),
                    TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validator.doubleValidator
                    )
                  ])),
          // buildUnitRow(),
        ]));
  }
}
