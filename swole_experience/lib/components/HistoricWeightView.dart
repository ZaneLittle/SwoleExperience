import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Weight.dart';
import '../service/WeightService.dart';

class HistoricWeightView extends StatefulWidget {
  const HistoricWeightView({Key? key}) : super(key: key);

  @override
  State<HistoricWeightView> createState() => _HistoricWeightViewState();
}

class _HistoricWeightViewState extends State<HistoricWeightView> {
  final GlobalKey<_HistoricWeightViewState> _historicWeightViewKey =
      GlobalKey<_HistoricWeightViewState>();
  final ScrollController _scrollController = ScrollController();
  bool _historicWeightViewExpanded = false;

  FutureBuilder buildList() {
    return FutureBuilder<List<Weight>>(
        future: WeightService.svc.getWeights(),
        builder: (BuildContext context, AsyncSnapshot<List<Weight>> snapshot) {
          // TODO: Proper dead states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading...'));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No weights have been logged'));
          } else {
            return ListView(
              controller: _scrollController,
              children: snapshot.data!.map((weight) {
                return buildRow(weight);
              }).toList(),
            );
          }
        });
  }

  Row buildRow(Weight weight) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child:
                  Text(DateFormat('yyyy-MM-dd HH:mm').format(weight.dateTime))),
          Text(weight.weight.toString()),
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // TODO: Update list
                    WeightService.svc.removeWeight(weight.id!);
                  }))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: _historicWeightViewKey,
      title: const Text('Historic Weight Data'),
      subtitle: const Text('See all of your past weight data and edit.'),
      children: <Widget>[
        SizedBox(height: 200, child: buildList()),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() => _historicWeightViewExpanded = expanded);
      },
    );
  }
}
