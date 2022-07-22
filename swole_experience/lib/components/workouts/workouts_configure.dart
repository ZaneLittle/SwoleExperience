import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/workouts/workout_create_update_form.dart';

import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/service/workout_service.dart';
import 'package:swole_experience/components/AlertSnackBar.dart';

class WorkoutsConfigure extends StatefulWidget {
  const WorkoutsConfigure({Key? key, this.context}) : super(key: key);

  final BuildContext? context;

  @override
  State<WorkoutsConfigure> createState() => _WorkoutsConfigureState();
}

class _WorkoutsConfigureState extends State<WorkoutsConfigure> {
  final GlobalKey<_WorkoutsConfigureState> _workoutsConfigureKey =
      GlobalKey<_WorkoutsConfigureState>();
  final ScrollController _scrollController = ScrollController();

  Map<int, List<Workout>> workoutMap = {
    1: [],
  };

  void initWorkoutMap(List<Workout> workouts) {
    for (var workout in workouts) {
      workoutMap[workout.day] != null
          ? workoutMap[workout.day]!.add(workout)
          : workoutMap[workout.day] = [workout];
    }
  }

  void addDay() {
    workoutMap[workoutMap.keys.last + 1] = [];
    setState(() {});
  }

  void addExercise() {
    // TODO: weight update/create page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WorkoutCreateUpdateForm(
                rebuildCallback: () => setState(() => {}))));
  }

  Widget buildAddDay() {
    return TextButton(
        onPressed: () {
          addDay();
        },
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle, color: CommonStyles.primaryColour),
                Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      'Add a Day',
                      style: TextStyle(color: CommonStyles.primaryColour),
                    ))
              ],
            )));
  }

  Widget buildAddExercise() {
    return TextButton(
        onPressed: () {
          addExercise();
        },
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle, color: CommonStyles.primaryColour),
                Padding(
                    padding: EdgeInsets.only(left: 24),
                    child: Text(
                      'Add an Exercise',
                      style: TextStyle(color: CommonStyles.primaryColour),
                    ))
              ],
            )));
  }

  Widget buildDay(List<Workout> workouts, int day) {
    return ExpansionTile(
        title: Text('Day ' + day.toString()),
        initiallyExpanded: true,
        children: [
          buildAddExercise(),
        ]);
  }

  Widget buildDays() {
    List<int> dayList = workoutMap.keys.toList();
    List<Widget> dayWidgetList =
        dayList.map((day) => buildDay(workoutMap[day]!, day)).toList();
    dayWidgetList.add(buildAddDay());

    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child:
            ListView(controller: _scrollController, children: dayWidgetList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 32,
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
          ),
          title: const Text('Configure workouts'),
        ),
        body: FutureBuilder<List<List<dynamic>>>(
            future: Future.wait([
              WorkoutService.svc.getWorkouts(),
              // PreferenceService.svc.getPreference()
            ]),
            builder: (BuildContext context,
                AsyncSnapshot<List<List<dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              } else {
                List<Workout> workouts =
                    snapshot.requireData[0] as List<Workout>;
                initWorkoutMap(workouts);

                return SizedBox(
                    // height: MediaQuery.of(context).size.height,
                    child: ListView(
                        controller: _scrollController,
                        children: <Widget>[
                      buildDays(),
                    ]));
              }
            }));
  }
}
