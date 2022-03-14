import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:swole_experience/components/HistoricWeightView.dart';
import 'package:swole_experience/constants/ChartDemoData.dart';

class WeightTracker extends StatefulWidget {
  const WeightTracker({Key? key}) : super(key: key);

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _weightEntryFieldFocusListener = FocusNode();
  Widget historicWeightView = HistoricWeightView();

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
    return Column(children: <Widget>[
      Container(
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
                  ]))),
      // TODO: ENHANCEMENT: close this if the historic view is open and vise versa thus giving more space - alternatively scroll the whole thing
      Container(
        height: 363,
          child: Padding(
              padding:
                  const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 32),
              child: LineChart(
                LineChartData(
                  // TODO: log and store user data
                  lineTouchData: DemoData.lineTouchData1,
                  gridData: DemoData.gridData,
                  titlesData: DemoData.titlesData1,
                  borderData: DemoData.borderData,
                  lineBarsData: DemoData.lineBarsData1,
                  minX: 0,
                  maxX: 14,
                  maxY: 4,
                  minY: 0,
                ),
                swapAnimationDuration: const Duration(milliseconds: 150),
                // Optional
                swapAnimationCurve: Curves.linear, // Optional
              ))),
      const HistoricWeightView(),
    ]);
  }
}