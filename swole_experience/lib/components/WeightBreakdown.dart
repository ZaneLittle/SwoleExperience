import 'package:flutter/material.dart';

import 'package:swole_experience/model/Average.dart';
import 'package:swole_experience/util/Util.dart';

class WeightBreakdown extends StatefulWidget {
  const WeightBreakdown({Key? key, this.context, this.dataSnapshot})
      : super(key: key);

  final BuildContext? context;
  final AsyncSnapshot<List<List<dynamic>>>? dataSnapshot;

  @override
  State<WeightBreakdown> createState() => _WeightBreakdownState();
}

class _WeightBreakdownState extends State<WeightBreakdown> {
  final GlobalKey<_WeightBreakdownState> _weightBreakdownKey =
      GlobalKey<_WeightBreakdownState>();
  final ScrollController _scrollController = ScrollController();

  bool _weightBreakdownExpanded = true;

  Widget buildChangeTile(int period, double change) {
    if (change > 0) {
      return Expanded(
          child: Card(
              child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          SizedBox(
              width: 70,
              child: Row(children: <Widget>[
                const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.arrow_drop_up)),
                Text(change.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ])),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('$period Day Change',
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ])
        ]),
      )));
    } else if (change < 0) {
      change *= -1;
      return Expanded(
          child: Card(
              child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          SizedBox(
              width: 70,
              child: Row(
                  children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_drop_down)),
                    Text(change.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ])),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('$period Day Change',
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ])
        ]),
      )));
      return Expanded(
          child: ListTile(
        leading: const Icon(Icons.arrow_drop_down),
        title: Text(change.toStringAsFixed(1)),
        subtitle: Text('$period Day Change'),
      ));
    } else {
      return Expanded(
          child: Card(
              child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          SizedBox(
              width: 70,
              child: Row(
                  children: <Widget>[
                    const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_right)),
                    Text(change.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ])),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('$period Day Change',
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ])
        ]),
      )));
    }
  }

  Widget buildSummary() {
    if (widget.dataSnapshot == null ||
        widget.dataSnapshot!.connectionState == ConnectionState.waiting) {
      return const Center(child: Text('Loading...'));
    } else if (!widget.dataSnapshot!.hasData ||
        widget.dataSnapshot!.data == null ||
        widget.dataSnapshot!.data!.isEmpty ||
        widget.dataSnapshot!.data![0].isEmpty ||
        widget.dataSnapshot!.data![0].isEmpty
    ) {
      return const Center(child: Text('No weights have been logged'));
    } else {
      List<Average> averages =
          widget.dataSnapshot!.requireData[1] as List<Average>;
      double currentWeight = ((averages.last.sevenDayAverage * 3) +
              (averages.last.threeDayAverage * 2) +
              (averages.last.average)) /
          6;
      int threeDayMax = averages.length < 3 ? averages.length : 3;
      int sevenDayMax = averages.length < 7 ? averages.length : 7;
      double threeDayChange =
          (averages[averages.length - threeDayMax].threeDayAverage -
              averages.last.threeDayAverage);
      double sevenDayChange =
          (averages[averages.length - sevenDayMax].sevenDayAverage -
              averages.last.sevenDayAverage);

      // TODO: icons for change direction & Styling
      // Up: arrow_drop_up
      // Down: arrow_drop_down
      // Same: arrow_right

      return ListView(controller: _scrollController, children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildChangeTile(3, threeDayChange),
            buildChangeTile(7, sevenDayChange),
            Expanded(
                child: Card(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(children: <Widget>[
                          Text(currentWeight.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Current Weight',
                              style: TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic)),
                        ])))),
          ],
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: _weightBreakdownKey,
      title: const Text('Breakdown Summary'),
      initiallyExpanded: _weightBreakdownExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() => _weightBreakdownExpanded = expanded);
        if (expanded) {
          Util().scrollToSelectedContext(_weightBreakdownKey);
        }
      },
      children: <Widget>[
        SizedBox(
          height: 90,
          child: buildSummary(),
        ),
      ],
    );
  }
}
