import 'package:flutter/material.dart';

class WeightEntryForm extends StatefulWidget {
  const WeightEntryForm({Key? key}) : super(key: key);

  @override
  State<WeightEntryForm> createState() => _WeightEntryFormState();
}

class _WeightEntryFormState extends State<WeightEntryForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _weightEntryFieldFocusListener = FocusNode();

  @override
  void initState() {
    _weightEntryFieldFocusListener.addListener(() {
      if (_weightEntryFieldFocusListener.hasFocus) {
        //TODO: BUG: Collapse historic view on focus or make whole page scrollale so overflow isnt broken
        // historicWeightView.setState(() => _historicWeightViewExpanded = false);
      }

      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        width: 240,
        padding: const EdgeInsets.only(top: 32),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    focusNode: _weightEntryFieldFocusListener,
                    //MediaQuery.of(context).viewInsets.bottom
                    decoration: InputDecoration(
                      hintText: 'Enter your weight',
                      suffixIcon: IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.arrow_circle_right),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: log the weight
                          }
                        },
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please a value';
                      }
                      return null;
                    },
                  ),
                ])));
  }
}
