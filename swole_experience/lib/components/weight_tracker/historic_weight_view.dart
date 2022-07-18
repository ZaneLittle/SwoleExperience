import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/components/weight_tracker/weight_edit_form.dart';
import 'package:swole_experience/model/weight.dart';
import 'package:swole_experience/service/weight_service.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/util/util.dart';
import 'package:swole_experience/components/AlertSnackBar.dart';
import 'package:swole_experience/service/average_service.dart';

class HistoricWeightView extends StatefulWidget {
  const HistoricWeightView(
      {Key? key,
      required this.context,
      required this.rebuildCallback,
      this.dataSnapshot})
      : super(key: key);

  final BuildContext context;
  final Function rebuildCallback;
  final AsyncSnapshot<List<List<dynamic>>>? dataSnapshot;

  @override
  State<HistoricWeightView> createState() => _HistoricWeightViewState();
}

class _HistoricWeightViewState extends State<HistoricWeightView> {
  final GlobalKey<_HistoricWeightViewState> _historicWeightViewKey =
      GlobalKey<_HistoricWeightViewState>();
  final ScrollController _scrollController = ScrollController();
  final Logger logger = Logger();

  bool _historicWeightViewExpanded = false;

  void deleteWeight(String? id, DateTime date) {
    if (id != null) {
      WeightService.svc.removeWeight(id).onError((error, stackTrace) {
        logger.e("Error deleting weight $error", stackTrace);
        const AlertSnackBar(
          message: 'Unable to delete weight.',
          state: SnackBarState.failure,
        ).alert(context);
        return 0;
      }).then((res) {
        if (res != 0) {
          AverageService.svc.calculateAverages(
              Converter().truncateToDay(date).toString());
        }
      }).then((res) {
        if (res != 0) {
          const AlertSnackBar(
            message: 'Deleted Weight!',
            state: SnackBarState.success,
          ).alert(context);
          setState(() {});
        }
      }).then((res) => res != 0 ? widget.rebuildCallback(context) : null);
    }
  }

  Widget buildList() {
    // TODO: Proper dead states
    if (widget.dataSnapshot == null ||
        widget.dataSnapshot!.connectionState == ConnectionState.waiting) {
      return const Center(child: Text('Loading...'));
    } else if (!widget.dataSnapshot!.hasData ||
        widget.dataSnapshot!.data == null ||
        widget.dataSnapshot!.data!.isEmpty ||
        widget.dataSnapshot!.data![0].isEmpty ||
        widget.dataSnapshot!.data![1].isEmpty
    ) {
      return const Center(child: Text('No weights have been logged'));
    } else {
      return ListView(
        controller: _scrollController,
        children: widget.dataSnapshot!.requireData[0].map((weight) {
          return buildRow(weight);
        }).toList(),
      );
    }
  }

  Row buildRow(Weight weight) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child:
                  Text(DateFormat('yyyy-MM-dd HH:mm').format(weight.dateTime))),
          Text(weight.weight.toStringAsFixed(2)),
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
                    deleteWeight(weight.id, weight.dateTime);
                  }))
        ]);
  }

  void editWeightModal(BuildContext context, Weight weight) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return SizedBox(child: WeightEditForm(weight: weight, rebuildCallback: widget.rebuildCallback));
        });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: _historicWeightViewKey,
      title: const Text('Historic Weight Data'),
      children: <Widget>[
        SizedBox(
            height: MediaQuery.of(context).size.height * .25,
            child: buildList()),
      ],
      initiallyExpanded: _historicWeightViewExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() => _historicWeightViewExpanded = expanded);
        if (expanded) {
          Util().scrollToSelectedContext(_historicWeightViewKey);
        }
      },
    );
  }
}
