import 'package:flutter/material.dart';
import 'package:swole_experience/components/HistoricWeightView.dart';
import 'package:swole_experience/components/WeightEntryForm.dart';
import 'package:swole_experience/components/WeightTrackerChart.dart';

class WeightTracker extends StatefulWidget {
  const WeightTracker({Key? key}) : super(key: key);

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  final ScrollController _scrollController = ScrollController();

  // TODO: ENHANCEMENT: close this if the historic view is open and vise
  //  versa thus giving more space - alternatively scroll the whole thing

  @override
  Widget build(BuildContext context) {
    return ListView(controller: _scrollController, children: <Widget>[
      Column(children: const <Widget>[
        WeightEntryForm(),
        WeightTrackerChart(),
        HistoricWeightView(),
      ])
    ]);
  }
}
