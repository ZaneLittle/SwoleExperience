import 'package:flutter/material.dart';

class HistoricWeightView extends StatefulWidget {
  const HistoricWeightView({Key? key}) : super(key: key);

  @override
  State<HistoricWeightView> createState() => _HistoricWeightViewState();
}

class _HistoricWeightViewState extends State<HistoricWeightView> {
  final GlobalKey<_HistoricWeightViewState> _historicWeightViewKey = GlobalKey<_HistoricWeightViewState>();
  final ScrollController _scrollController = ScrollController();
  bool _historicWeightViewExpanded = false;

  // TODO: TMP: Mocked data
  List<Widget> buildList() {
    return <Widget>[
      buildRow('17/03/2022', '162'),
      buildRow('10/03/2022', '161'),
      buildRow('03/03/2022', '160'),
      buildRow('20/02/2022', '163'),
      buildRow('13/02/2022', '159'),
      buildRow('04/02/2022', '162'),
      buildRow('23/01/2022', '164'),
      buildRow('14/01/2022', '163'),
      buildRow('07/01/2022', '163'),
    ];
  }

  Row buildRow(String date, String weight) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(date)),
      Text(weight),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: IconButton(icon: const Icon(Icons.edit), onPressed: () {}))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: _historicWeightViewKey,
      title: const Text('Historic Weight Data'),
      subtitle: const Text('See all of your past weight data and edit.'),
      children: <Widget>[
        Container(height: 200, child: ListView(controller: _scrollController, children: buildList())),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() => _historicWeightViewExpanded = expanded);
      },
    );
  }
}
