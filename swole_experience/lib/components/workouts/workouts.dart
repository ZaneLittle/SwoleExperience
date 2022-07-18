import 'package:flutter/material.dart';
import 'package:swole_experience/components/workouts/timer.dart';
import 'package:swole_experience/components/workouts/workout_list.dart';
import 'package:swole_experience/constants/common_styles.dart';

class Workouts extends StatefulWidget {
  const Workouts({Key? key, this.context}) : super(key: key);

  final BuildContext? context;

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  final GlobalKey<_WorkoutsState> _workoutsKey = GlobalKey<_WorkoutsState>();

  int day = 1; // TODO: hook up to preferences
  String dayText = 'Today';

  Widget buildDaySelect() {
    return SizedBox(
      height: 48,
      child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_left,
                      color: CommonStyles.primaryColour)),
              Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(dayText,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_right,
                      color: CommonStyles.primaryColour)),
            ],
          )),
    );
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
