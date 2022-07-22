import 'dart:async';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/weight_tracker/historic_weight_view.dart';
import 'package:swole_experience/components/weight_tracker/weight_entry_form.dart';
import 'package:swole_experience/components/weight_tracker/weight_breakdown.dart';
import 'package:swole_experience/components/weight_tracker/weight_tracker_chart.dart';
import 'package:swole_experience/service/average_service.dart';
import 'package:swole_experience/service/weight_service.dart';
import 'package:swole_experience/components/preferences/settings_button.dart';


class WeightTracker extends StatefulWidget {
  const WeightTracker({Key? key}) : super(key: key);

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  final ScrollController _scrollController = ScrollController();

  FutureOr rebuild(dynamic val) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<dynamic>>>(
        future: Future.wait([
          WeightService.svc.getWeights(startDate: DateTime.now()),
          AverageService.svc.getAverages(startDate: DateTime.now())
        ]),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<dynamic>>> snapshot) {
          return ListView(controller: _scrollController, children: <Widget>[
            Column(children: <Widget>[
              Row(children: <Widget>[
                SettingsButton(rebuildCallback: rebuild),
                WeightEntryForm(context: context, rebuildCallback: rebuild)
              ]),
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
