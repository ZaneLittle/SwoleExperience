import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../Weight.dart';
import '../service/WeightService.dart';
import '../util/Validator.dart';

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

  void logWeight(String value) {
    double? weightVal = double.parse(value);

    // Close keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    // Show success
    _weightController.value = TextEditingValue.empty;

    WeightService.svc.addWeight(Weight(
        id: const Uuid().v1(), weight: weightVal, dateTime: DateTime.now()));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.thumb_up),
                SizedBox(
                  width: 20,
                ),
                Text('Added Weight!'),
              ],
            ))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height *.2,
        width: MediaQuery.of(context).size.width *.5,
        padding: const EdgeInsets.only(top: 32),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // TODO: sizing and hooking up to create
                  // DateTimeField(
                  //     format: DateFormat('yyyy-MM-dd HH:mm'),
                  //     controller: _dateController,
                  //     decoration: InputDecoration(
                  //         hintText: DateFormat('yyyy-MM-dd HH:mm')
                  //             .format(DateTime.now())),
                  //     onShowPicker: (context, currentValue) async {
                  //       final date = await showDatePicker(
                  //           context: context,
                  //           firstDate: DateTime(1900),
                  //           initialDate: currentValue ?? DateTime.now(),
                  //           lastDate: DateTime(2100));
                  //       if (date != null) {
                  //         final time = await showTimePicker(
                  //           context: context,
                  //           initialTime: TimeOfDay.fromDateTime(
                  //               currentValue ?? DateTime.now()),
                  //         );
                  //         return DateTimeField.combine(date, time);
                  //       } else {
                  //         return currentValue;
                  //       }
                  //     }),
                  TextFormField(
                    // focusNode: _weightEntryFieldFocusListener,
                    controller: _weightController,
                    //MediaQuery.of(context).viewInsets.bottom
                    decoration: InputDecoration(
                      hintText: 'Enter your weight',
                      suffixIcon: IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.arrow_circle_right),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            logWeight(_weightController.value.text);
                          }
                        },
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (String? value) {
                      return Validator.doubleValidator(value);
                    },
                    onFieldSubmitted: (value) {
                      if (_formKey.currentState!.validate()) {
                        logWeight(value);
                      }
                    },
                  ),
                ])));
  }
}
