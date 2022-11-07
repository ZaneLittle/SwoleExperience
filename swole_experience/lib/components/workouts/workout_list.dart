import 'dart:async';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workouts_configure.dart';
import 'package:swole_experience/components/workouts/workout_card.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/model/workout_day.dart';
import 'package:swole_experience/model/workout_history.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList(
      {Key? key,
      this.context,
      required this.dataSnapshot,
      required this.rebuildCallback,
      required this.history})
      : super(key: key);

  final BuildContext? context;
  final AsyncSnapshot<List<List<dynamic>>> dataSnapshot;
  final Function rebuildCallback;
  final bool history;

  @override
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  final GlobalKey<_WorkoutListState> _workoutListKey =
      GlobalKey<_WorkoutListState>();
  final ScrollController _scrollController = ScrollController();

  FutureOr rebuild(
      {WorkoutDay? workout, bool delete = false, bool update = false}) {
    setState(() {});
    widget.rebuildCallback(workout);
  }

  FutureOr rebuildDynamic(dynamic value) => rebuild(workout: value);

  bool dataIsEmpty() =>
      !widget.dataSnapshot.hasData ||
      widget.dataSnapshot.data == null ||
      widget.dataSnapshot.data!.isEmpty ||
      widget.dataSnapshot.data![0].isEmpty;

  ///                             Widgets                                    ///
  Widget buildHistoryHeader() {
    return const Padding(
        padding: EdgeInsets.only(top: 24, bottom: 8),
        child: Align(
            alignment: Alignment.center,
            child: Text(
              'Completed',
              style: TextStyle(color: CommonStyles.primaryColour),
            )));
  }

  TextButton buildAddWorkoutPlaceholder() {
    return TextButton(
        onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WorkoutsConfigure()))
              .then(rebuildDynamic);
        },
        child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle, color: CommonStyles.primaryColour),
                Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      'Add a workout',
                      style: TextStyle(color: CommonStyles.primaryColour),
                    ))
              ],
            )));
  }

  TextButton buildGoToTodayPlaceholder() {
    return TextButton(
        onPressed: () {
          rebuild();
        },
        child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text(
                      'No workouts logged this day',
                      style: TextStyle(color: CommonStyles.primaryColour),
                    )),
                Icon(Icons.arrow_circle_right,
                    color: CommonStyles.primaryColour),
                Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      'Go to today',
                      style: TextStyle(color: CommonStyles.primaryColour),
                    ))
              ],
            )));
  }

  Widget buildList() {
    if (widget.dataSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: Text('Loading...'));
    } else if (!widget.history && dataIsEmpty()) {
      return buildAddWorkoutPlaceholder();
    } else if (dataIsEmpty()) {
      return buildGoToTodayPlaceholder();
    } else {
      return ListView(
        controller: _scrollController,
        children: widget.dataSnapshot.requireData
            .map((data) {
              List<Widget> cards = [];
              List<WorkoutDay> workoutsInDay = [];
              if (data.isNotEmpty) {
                if (data.first is WorkoutHistory) {
                  cards = [buildHistoryHeader()];
                } else if (data.first is WorkoutDay) {
                  workoutsInDay = data as List<WorkoutDay>;
                }
                if (data.first is WorkoutDay || data.first is WorkoutHistory) {
                  cards.addAll(data.map((w) {
                    return WorkoutCard(
                      workout: w,
                      rebuildCallback: rebuild,
                      workoutsInDay: workoutsInDay,
                    );
                  }));
                }
              }
              return cards;
            })
            .expand((e) => e)
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _workoutListKey,
      height: MediaQuery.of(context).size.height - 240,
      child: buildList(),
    );
  }
}
