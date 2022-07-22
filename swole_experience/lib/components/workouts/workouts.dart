import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/preferences/settings_button.dart';
import 'package:swole_experience/components/workouts/timer.dart';
import 'package:swole_experience/components/workouts/workout_list.dart';
import 'package:swole_experience/constants/common_styles.dart';

import '../preferences/settings.dart';

class Workouts extends StatefulWidget {
  const Workouts({Key? key, this.context}) : super(key: key);

  final BuildContext? context;

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  final GlobalKey<_WorkoutsState> _workoutsKey = GlobalKey<_WorkoutsState>();

  FutureOr rebuild(dynamic value) {
    setState(() {});
  }

  int day = 1; // TODO: hook up to preferences
  String dayText = 'Today';

  Widget buildDaySelect() {
    // TODO: Dont show day select (only settings) if no workouts available
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: const EdgeInsets.only(top: 0), child: SettingsButton(rebuildCallback: rebuild)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_left,
                      color: CommonStyles.primaryColour)),
              Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(dayText,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_right,
                      color: CommonStyles.primaryColour)),
              const SizedBox(width: 64)
            ],
          ));
    // ); // );
  }

  Widget buildList() {
    return Column(
      children: [
        buildDaySelect(),
        WorkoutList(day: day),
        ElevatedButton(
            onPressed: () {}, // TODO: hook up to preferences
            child: const Text('Complete Day'),
            style:
                ElevatedButton.styleFrom(primary: CommonStyles.primaryColour)),
        const WorkoutTimer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _workoutsKey,
      child: buildList(),
    );
  }
}
