import 'dart:async';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workouts_configure.dart';
import 'package:swole_experience/components/workouts/workout_card.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList(
      {Key? key,
      this.context,
      required this.dataSnapshot,
      required this.rebuildCallback})
      : super(key: key);

  final BuildContext? context;
  final AsyncSnapshot<List<List<dynamic>>> dataSnapshot;
  final Function rebuildCallback;

  @override
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  final GlobalKey<_WorkoutListState> _workoutListKey =
      GlobalKey<_WorkoutListState>();
  final ScrollController _scrollController = ScrollController();

  FutureOr rebuild({Workout? workout, bool delete = false, bool update = false}) {
    setState(() {});
    widget.rebuildCallback(workout);
  }

  FutureOr rebuildDynamic(dynamic value) => rebuild(workout: value);

  Widget buildList() {
    if (widget.dataSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: Text('Loading...'));
    } else if (!widget.dataSnapshot.hasData ||
        widget.dataSnapshot.data == null ||
        widget.dataSnapshot.data!.isEmpty ||
        widget.dataSnapshot.data![0].isEmpty) {
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
    } else {
      return ListView(
        controller: _scrollController,
        children: widget.dataSnapshot.requireData[0]
            .map((w) => WorkoutCard(
                  workout: w,
                  rebuildCallback: rebuild,
                ))
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
