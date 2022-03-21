import 'package:flutter/material.dart';

import '../components/HistoricWeightView.dart';
import '../components/WeightEntryForm.dart';
import '../components/WeightTrackerChart.dart';
import '../service/AverageService.dart';
import '../service/WeightService.dart';

class WeightTracker extends StatefulWidget {
  const WeightTracker({Key? key}) : super(key: key);

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  final ScrollController _scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<dynamic>>>(
      future: Future.wait([WeightService.svc.getWeights(), AverageService.svc.getAverages()]),
      builder: (BuildContext context, AsyncSnapshot<List<List<dynamic>>> snapshot) {
        return ListView(controller: _scrollController, children: <Widget>[
          Column(children: <Widget>[
            const WeightEntryForm(),
            WeightTrendChart(context: context, dataSnapshot: snapshot),
            HistoricWeightView(context: context, dataSnapshot: snapshot),
          ])
        ]);
      }
    );

  }
}
