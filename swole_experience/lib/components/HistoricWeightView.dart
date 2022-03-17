import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole_experience/components/WeightEditForm.dart';

import '../model/Weight.dart';
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
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                editWeightModal(context, weight);
              }),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    WeightService.svc.removeWeight(weight.id!).then((res) =>
                        build(context) // TODO: not actually building
                    );
                  }))
        ]);
  }

  void editWeightModal(BuildContext context, Weight weight) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return SizedBox(
              child: WeightEditForm(weight: weight));
        });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: _historicWeightViewKey,
      title: const Text('Historic Weight Data'),
      children: <Widget>[
        SizedBox(
            height: MediaQuery.of(context).size.height * .225,
            child: buildList()),
      ],
      initiallyExpanded: _historicWeightViewExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() => _historicWeightViewExpanded = expanded);
      },
    );
  }
}
