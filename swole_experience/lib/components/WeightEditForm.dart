import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:swole_experience/util/Converter.dart';

import '../model/Weight.dart';
import '../service/AverageService.dart';
import '../service/WeightService.dart';
import '../util/Validator.dart';
import 'AlertSnackBar.dart';

class WeightEditForm extends StatefulWidget {
  const WeightEditForm({Key? key, required this.weight}) : super(key: key);

  final Weight weight;

  @override
  State<WeightEditForm> createState() => _WeightEditFormState();
}

class _WeightEditFormState extends State<WeightEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void updateWeight() {
    if (_weightController.value.text.isNotEmpty ||
        _dateController.value.text.isNotEmpty) {
      DateTime updatedDateTime = _dateController.value.text.isNotEmpty
          ? DateTime.parse(_dateController.value.text)
          : widget.weight.dateTime;
      double updatedWeightValue = _weightController.value.text.isNotEmpty
          ? double.parse(_weightController.value.text)
          : widget.weight.weight;

      Weight updatedWeight = Weight(
          id: widget.weight.id,
          dateTime: updatedDateTime,
          weight: updatedWeightValue);

      WeightService.svc.updateWeight(updatedWeight).then((int r) {
        if (r != 0) {
          DateTime roundedDate = Converter().truncateToDay(updatedDateTime);
          AverageService.svc.calculateAverages(roundedDate.toString());
        }
      }).onError((error, stackTrace) {
        // TODO: add proper logger
        print("Error updating weight $error\n$stackTrace");
        const AlertSnackBar(
          message: 'Unable to update weight.',
          state: SnackBarState.failure,
        ).alert(context);
      }).then((res) {
        if (res != 0) {
          const AlertSnackBar(
            message: 'Weight Updated!',
            state: SnackBarState.success,
          ).alert(context);
        }
      });
      // TODO Update chart and table
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: MediaQuery.of(context).size.width * .25),
                child: DateTimeField(
                    format: DateFormat('yyyy-MM-dd HH:mm'),
                    controller: _dateController,
                    decoration: InputDecoration(
                        hintText: DateFormat('yyyy-MM-dd HH:mm')
                            .format(widget.weight.dateTime)),
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    })),
            Padding(
                padding: EdgeInsets.symmetric(
                    // vertical: 8,
                    horizontal: MediaQuery.of(context).size.width * .25),
                child: TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (String? value) {
                      return Validator.doubleValidatorNullAllowed(value);
                    },
                    decoration: InputDecoration(
                        hintText: widget.weight.weight.toString()))),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.arrow_circle_right),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateWeight();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ]),
          ],
        ));
  }
}
