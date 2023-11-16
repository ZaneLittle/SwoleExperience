import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'package:swole_experience/model/weight.dart';
import 'package:swole_experience/service/db/average_service.dart';
import 'package:swole_experience/service/db/weight_service.dart';
import 'package:swole_experience/util/validator.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/components/alert_snack_bar.dart';

class WeightEntryForm extends StatefulWidget {
  const WeightEntryForm(
      {Key? key, required this.context, required this.rebuildCallback})
      : super(key: key);

  final BuildContext context;
  final Function rebuildCallback;

  @override
  State<WeightEntryForm> createState() => _WeightEntryFormState();
}

class _WeightEntryFormState extends State<WeightEntryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Logger logger = Logger();
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
            .calculateAverages(Converter.truncateToDay(dateTime).toString())
            .then((res) {
          if (res != 0) {
            const AlertSnackBar(
              message: 'Weight Added!',
              state: SnackBarState.success,
            ).alert(context);
          }
        }).onError((error, stackTrace) {
          logger.e("Error calculating averages $error", stackTrace: stackTrace);
          const AlertSnackBar(
            message: 'Unable to calculate averages.',
            state: SnackBarState.failure,
          ).alert(context);
        }).then((res) => res != 0 ? widget.rebuildCallback(context) : null);
      }
    }).onError((error, stackTrace) {
      logger.e("Error adding weight $error", stackTrace: stackTrace);
      const AlertSnackBar(
        message: 'Unable to add weight.',
        state: SnackBarState.failure,
      ).alert(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: 300,
        padding: const EdgeInsets.only(top: 12),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            child: SizedBox(
                                width: 95,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: DateTimeField(
                                        format: DateFormat('yyyy-MM-dd HH:mm'),
                                        controller: _dateController,
                                        decoration: InputDecoration(
                                            hintText:
                                                DateFormat('MM/dd HH:mm')
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
                        Center(
                            child: SizedBox(
                                width: 180,
                                child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: TextFormField(
                                  controller: _weightController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter weight',
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
                                )))),
                      ])
                ])));
  }
}
