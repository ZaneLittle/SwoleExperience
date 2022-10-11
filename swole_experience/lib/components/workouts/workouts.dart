import 'dart:async';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/preferences/settings_button.dart';
import 'package:swole_experience/components/workouts/timer.dart';
import 'package:swole_experience/components/workouts/workout_list.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/pages.dart';
import 'package:swole_experience/constants/preference_constants.dart';
import 'package:swole_experience/model/preference.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/service/preference_service.dart';
import 'package:swole_experience/service/workout_service.dart';


class Workouts extends StatefulWidget {
  const Workouts({Key? key, this.context}) : super(key: key);

  final BuildContext? context;

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  final GlobalKey<_WorkoutsState> _workoutsKey = GlobalKey<_WorkoutsState>();

  int totalOffset = 0;
  int workingOffset = 0;
  int day = 1;
  String dayText = 'Today';

  FutureOr rebuild(Workout? value) {
    setState(() {});
    build(context);
  }

  void updateView(int offset) {
    workingOffset += offset;
    totalOffset += offset;

    WorkoutService.svc.getUniqueDays().then((daysLength) {
      if (workingOffset + day < 1) {
        workingOffset = daysLength - day;
      } else if (workingOffset + day > daysLength) {
        workingOffset = 1 - day;
      }

      setState(() {
        workingOffset = workingOffset;
      });
    });
  }

  Widget buildDaySelect(AsyncSnapshot<List<List<dynamic>>> dataSnapshot) {
    return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 0),
                child: SettingsButton(rebuildCallback: rebuild)),
            isWorkoutsPopulated(dataSnapshot)
                ? IconButton(
                    onPressed: () => updateView(-1),
                    icon: const Icon(Icons.keyboard_arrow_left,
                        color: CommonStyles.primaryColour))
                : Container(),
            isWorkoutsPopulated(dataSnapshot)
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(dayText,
                        style: const TextStyle(fontWeight: FontWeight.bold)))
                : Container(),
            isWorkoutsPopulated(dataSnapshot)
                ? IconButton(
                    onPressed: () => updateView(1),
                    icon: const Icon(Icons.keyboard_arrow_right,
                        color: CommonStyles.primaryColour))
                : Container(),
            const SizedBox(width: 64)
          ],
        ));
  }

  Widget buildCompleteDayButton(
      AsyncSnapshot<List<List<dynamic>>> dataSnapshot) {
    if (!isWorkoutsPopulated(dataSnapshot)) {
      return Container();
    } else {
      return ElevatedButton(
          onPressed: () {
            WorkoutService.svc.getUniqueDays().then((daysLength) {
              workingOffset = 0;
              totalOffset = 0;
              day = (day < daysLength) ? day + 1 : 1;

              Preference newWorkoutDay = Preference(
                preference: PreferenceConstant.workoutDayKey,
                value: day.toString(),
                lastUpdated: DateTime.now(),
              );
              PreferenceService.svc.setPreference(newWorkoutDay);

              setState(() {});
            });
          },
          child: const Text('Complete Day'),
          style: ElevatedButton.styleFrom(primary: CommonStyles.primaryColour));
    }
  }

  bool isWorkoutsPopulated(AsyncSnapshot<List<List<dynamic>>> dataSnapshot) {
    return dataSnapshot.data?[0].isNotEmpty ?? false;
  }

  void setupDay({List<Preference>? dayPref, int offset = 0}) {
    day = (dayPref != null && dayPref.isNotEmpty && dayPref[0].value != null)
        ? int.parse(dayPref[0].value!)
        : 1;

    switch (totalOffset) {
      case 0:
        {
          dayText = "    Today    ";
        }
        break;
      case -1:
        {
          dayText = "Yesterday";
        }
        break;
      case 1:
        {
          dayText = "Tomorrow ";
        }
        break;
      default:
        {
          dayText = (totalOffset > 0)
              ? "In $totalOffset Days"
              : "${totalOffset * -1} Days Ago";
        }
        break;
    }
  }

  Widget buildList(int? dayOffset) {
    return FutureBuilder<List<List<dynamic>>>(
        future: Future.wait([
          PreferenceService.svc.getPreference(PreferenceConstant.workoutDayKey),
        ]),
        builder: (BuildContext context,
            AsyncSnapshot<List<List<dynamic>>> initSnapshot) {
          if (initSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading...'));
          } else {
            setupDay(
                dayPref: initSnapshot.data?[0] as List<Preference>?,
                offset: dayOffset ?? 0);
            return FutureBuilder<List<List<dynamic>>>(
              future: Future.wait([
                WorkoutService.svc.getWorkouts(day: day + (dayOffset ?? 0)),
              ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<List<dynamic>>> finalSnapshot) {

                finalSnapshot.data?.add(initSnapshot.data ?? []);

                return Column(
                  children: [
                    buildDaySelect(finalSnapshot),
                    WorkoutList(dataSnapshot: finalSnapshot, rebuildCallback: rebuild),
                    buildCompleteDayButton(finalSnapshot),
                    const WorkoutTimer(),
                  ],
                );
              }
            );
          }
        });
  }

  @override
  Widget build(BuildContext context, {int? dayOffset}) {
    if (dayOffset != null) {
      workingOffset = dayOffset;
    }

    return SizedBox(
      key: _workoutsKey,
      child: buildList(workingOffset),
    );
  }
}
