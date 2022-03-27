import 'package:flutter/material.dart';

import 'package:swole_experience/components/HistoricWeightView.dart';
import 'package:swole_experience/components/WeightEntryForm.dart';
import 'package:swole_experience/components/WeightBreakdown.dart';
import 'package:swole_experience/components/WeightTrackerChart.dart';
import 'package:swole_experience/service/AverageService.dart';
import 'package:swole_experience/service/WeightService.dart';

class WeightTracker extends StatefulWidget {
  const WeightTracker({Key? key}) : super(key: key);

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  final ScrollController _scrollController = ScrollController();

  void rebuild(BuildContext context) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<dynamic>>>(
        future: Future.wait(
            [WeightService.svc.getWeights(), AverageService.svc.getAverages()]),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<dynamic>>> snapshot) {
          return ListView(controller: _scrollController, children: <Widget>[
            Column(children: <Widget>[
              WeightEntryForm(context: context, rebuildCallback: rebuild),
              WeightBreakdown(context: context, dataSnapshot: snapshot),
              WeightTrendChart(context: context, dataSnapshot: snapshot),
              HistoricWeightView(
                  context: context,
                  rebuildCallback: rebuild,
                  dataSnapshot: snapshot),
            ])
          ]);
        });
  }
}
