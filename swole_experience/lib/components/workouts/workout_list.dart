import 'dart:async';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workouts_configure.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/service/workout_service.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/components/workouts/workout_card.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({Key? key, this.context, required this.day})
      : super(key: key);

  final BuildContext? context;
  final int day;

  @override
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  final GlobalKey<_WorkoutListState> _workoutListKey =
      GlobalKey<_WorkoutListState>();
  final ScrollController _scrollController = ScrollController();

  FutureOr rebuild(dynamic value) {
    setState(() {});
  }

  Widget buildList(AsyncSnapshot<List<Workout>> dataSnapshot) {
    if (dataSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: Text('Loading...'));
    } else if (!dataSnapshot.hasData ||
        dataSnapshot.data == null ||
        dataSnapshot.data!.isEmpty) {
      return TextButton(
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkoutsConfigure()))
                .then(rebuild);
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
        children: dataSnapshot.requireData.map((w) {
          return WorkoutCard(workout: w);
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Workout>>(
        future: WorkoutService.svc.getWorkouts(day: widget.day),
        builder: (BuildContext context, AsyncSnapshot<List<Workout>> snapshot) {
          return SizedBox(
            key: _workoutListKey,
            height: MediaQuery.of(context).size.height - 240,
            child: buildList(snapshot),
          );
        });
  }
}
