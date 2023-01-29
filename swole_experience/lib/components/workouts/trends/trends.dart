import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/workouts/trends/workout_history_chart.dart';
import 'package:swole_experience/components/workouts/trends/workout_history_list.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout_history.dart';

import 'package:swole_experience/service/workout_history_service.dart';

class Trends extends StatefulWidget {
  const Trends({Key? key}) : super(key: key);

  @override
  State<Trends> createState() => _TrendsState();
}

class _TrendsState extends State<Trends> {
  Map<String, List<WorkoutHistory>> _workoutMap = {};
  String? _selectedWorkout;

  bool hasWorkouts() => _workoutMap[_selectedWorkout]?.isNotEmpty ?? false;

  Widget buildDropdown() {
    List<String> workoutIds = _workoutMap.keys.toList();

    return Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: DropdownButton(
                value: _selectedWorkout,
                items: workoutIds
                    .map((id) => DropdownMenuItem(
                        child: Text(_workoutMap[id]!.first.name), value: id))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWorkout = value.toString();
                  });
                })));
  }

  ///                           Build                                        ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CommonStyles.primaryDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 32,
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
          title: const Text('Workout Trends'),
        ),
        body: FutureBuilder<List<dynamic>>(
            future: Future.wait([
              WorkoutHistoryService.svc.getWorkoutHistoryMap(),
            ]),
            builder: (BuildContext context,
                AsyncSnapshot<List<dynamic>> initSnapshot) {
              if (initSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              } else {
                if (initSnapshot.data?.first != null) {
                  _workoutMap = initSnapshot.data!.first;
                  _selectedWorkout ??= _workoutMap.keys.first;

                  return Column(
                    children: [
                      buildDropdown(),
                      hasWorkouts() ? WorkoutHistoryChart(workouts: _workoutMap[_selectedWorkout]!) : Container(),
                      hasWorkouts() ? WorkoutHistoryList(
                          context: context,
                          workouts: _workoutMap[_selectedWorkout]!) : Container(),
                    ],
                  );
                } else {
                  return const Center(
                      child: Text(
                    'Complete some workouts to see your trends!',
                    style: TextStyle(color: CommonStyles.primaryColour),
                  ));
                }
              }
            }));
  }
}
