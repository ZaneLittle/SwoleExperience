import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../Weight.dart';
import '../service/WeightService.dart';

// TODO: ENHANCEMENT: allow user to select time and date
class WeightEntryForm extends StatefulWidget {
  const WeightEntryForm({Key? key}) : super(key: key);

  @override
  State<WeightEntryForm> createState() => _WeightEntryFormState();
}

class _WeightEntryFormState extends State<WeightEntryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _weightEntryFieldFocusListener = FocusNode();
  final textController = TextEditingController();

  // @override
  // void initState() {
  //   _weightEntryFieldFocusListener.addListener(() {
  //     if (_weightEntryFieldFocusListener.hasFocus) {
  //       //TODO: BUG: Collapse historic view on focus or make whole page scrollale so overflow isnt broken
  //       // historicWeightView.setState(() => _historicWeightViewExpanded = false);
  //     }
  //
  //     super.initState();
  //   });
  // }

  void logWeight(String value) {
    double? weightVal = double.tryParse(value);
    if (weightVal == null) {
      throw Exception('$value made it past validator but could not be parsed');
    }

    // TODO: close keyboard and show success message
    FocusScope.of(context);

    WeightService.svc.addWeight(Weight(
      id: const Uuid().v1(),
      weight: weightVal,
      dateTime: DateTime.now()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 95,
        width: 240,
        padding: const EdgeInsets.only(top: 32),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    // focusNode: _weightEntryFieldFocusListener,
                    controller: textController,
                    //MediaQuery.of(context).viewInsets.bottom
                    decoration: InputDecoration(
                      hintText: 'Enter your weight',
                      suffixIcon: IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.arrow_circle_right),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            logWeight(textController.value.text);
                          }
                        },
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please a value';
                      } if (double.tryParse(value) == null) {
                        return 'Entry must be numeric';
                      }
                      return null;
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
