import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole_experience/service/AverageService.dart';
import 'package:uuid/uuid.dart';

import '../model/Weight.dart';
import '../service/WeightService.dart';
import '../util/Validator.dart';
import '../util/Converter.dart';
import 'AlertSnackBar.dart';

// TODO: ENHANCEMENT: allow user to select time and date
class WeightEntryForm extends StatefulWidget {
  const WeightEntryForm({Key? key}) : super(key: key);

  @override
  State<WeightEntryForm> createState() => _WeightEntryFormState();
}

class _WeightEntryFormState extends State<WeightEntryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  void logWeight() {
    double? weightVal = double.parse(_weightController.value.text);
    DateTime dateTime = DateTime.tryParse(_dateController.value.text) != null
        ? DateTime.parse(_dateController.value.text)
        : DateTime.now();

    // Close keyboard and clear fields
    FocusScope.of(context).requestFocus(FocusNode());
    _weightController.value = TextEditingValue.empty;
    _dateController.value = TextEditingValue.empty;

    WeightService.svc
        .addWeight(Weight(
            id: const Uuid().v1(), weight: weightVal, dateTime: dateTime))
        .then((int r) {
      if (r != 0) {
        AverageService.svc
            .calculateAverages(Converter().truncateToDay(dateTime).toString());
      }
    }).onError((error, stackTrace) {
      // TODO: add proper logger
      print("Error adding weight $error\n$stackTrace");
      const AlertSnackBar(
        message: 'Unable to add weight.',
        state: SnackBarState.failure,
      ).alert(context);
    }).then((res) {
      if (res != 0) {
        const AlertSnackBar(
          message: 'Weight Added!',
          state: SnackBarState.success,
        ).alert(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * .125,
        width: MediaQuery.of(context).size.width * .9,
        padding: const EdgeInsets.only(top: 12),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                      // TODO: Elements need better styling and input needs to be hooked up to create
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            child: SizedBox(
                                width: 130,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: DateTimeField(
                                        format: DateFormat('yyyy-MM-dd HH:mm'),
                                        controller: _dateController,
                                        decoration: InputDecoration(
                                            hintText:
                                                DateFormat('yyyy-MM-dd HH:mm')
                                                    .format(DateTime.now())),
                                        onShowPicker:
                                            (context, currentValue) async {
                                          final date = await showDatePicker(
                                              context: context,
                                              firstDate: DateTime(1900),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              lastDate: DateTime(2100));
                                          if (date != null) {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  TimeOfDay.fromDateTime(
                                                      currentValue ??
                                                          DateTime.now()),
                                            );
                                            return DateTimeField.combine(
                                                date, time);
                                          } else {
                                            return currentValue;
                                          }
                                        })))),
                        Flexible(
                            child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: TextFormField(
                                  // focusNode: _weightEntryFieldFocusListener,
                                  controller: _weightController,
                                  //MediaQuery.of(context).viewInsets.bottom
                                  decoration: InputDecoration(
                                    hintText: 'Enter your weight',
                                    suffixIcon: IconButton(
                                      iconSize: 32,
                                      icon:
                                          const Icon(Icons.arrow_circle_right),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          logWeight();
                                        }
                                      },
                                    ),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (String? value) {
                                    return Validator.doubleValidator(value);
                                  },
                                  onFieldSubmitted: (value) {
                                    if (_formKey.currentState!.validate()) {
                                      logWeight();
                                    }
                                  },
                                ))),
                      ])
                ])));
  }
}
