import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/components/weight_tracker/weight_edit_form.dart';
import 'package:swole_experience/model/weight.dart';
import 'package:swole_experience/model/workout_history.dart';
import 'package:swole_experience/service/db/weight_service.dart';
import 'package:swole_experience/util/converter.dart';
import 'package:swole_experience/util/util.dart';
import 'package:swole_experience/components/alert_snack_bar.dart';
import 'package:swole_experience/service/db/average_service.dart';
import 'package:swole_experience/util/weight_util.dart';

class WorkoutHistoryList extends StatefulWidget {
  const WorkoutHistoryList(
      {Key? key, required this.context, required this.workouts})
      : super(key: key);

  final BuildContext context;
  final List<WorkoutHistory> workouts;

  @override
  State<WorkoutHistoryList> createState() => _WorkoutHistoryListState();
}

class _WorkoutHistoryListState extends State<WorkoutHistoryList> {
  final GlobalKey<_WorkoutHistoryListState> _workoutHistoryListKey =
      GlobalKey<_WorkoutHistoryListState>();
  final ScrollController _scrollController = ScrollController();
  final Logger logger = Logger();

  bool _expanded = true;

  Widget buildList() {
    return ListView(
      controller: _scrollController,
      children: widget.workouts.reversed.map((workout) {
        return buildRow(workout);
      }).toList(),
    );
  }

  Row buildRow(WorkoutHistory workout) {
    int oneRM = WeightUtil.calculateOneRepMax(workout);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 100, top: 12, bottom: 12),
              child: Text(formatter.format(DateTime.parse(workout.date)))),
          Padding(
              padding: const EdgeInsets.only(right: 100, top: 12, bottom: 12),
              child: Text(oneRM.toString())),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: _workoutHistoryListKey,
      title: const Text('Calculated One Rep Max History'),
      children: <Widget>[
        SizedBox(
            height: MediaQuery.of(context).size.height * .25,
            child: buildList()),
      ],
      initiallyExpanded: _expanded,
      onExpansionChanged: (bool expanded) {
        setState(() => _expanded = expanded);
        if (expanded) {
          Util().scrollToSelectedContext(_workoutHistoryListKey);
        }
      },
    );
  }
}
