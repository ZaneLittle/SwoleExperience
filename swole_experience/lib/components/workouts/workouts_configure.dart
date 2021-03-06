import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/workouts/workout_card.dart';
import 'package:swole_experience/components/workouts/workout_create_update_form.dart';

import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/service/workout_service.dart';

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
    for (int key in workoutMap.keys) {
      workoutMap[key] = [];
    }

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

  void addExercise(int day, int defaultOrder) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return SizedBox(
              child: WorkoutCreateUpdateForm(
                  day: day,
                  defaultOrder: defaultOrder,
                  rebuildCallback: (Workout workout) {
                    workoutMap[workout.day]!.add(workout);
                    setState(() => {});
                    build(context);
                  }));
        });
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

  Widget buildAddExercise(int day, int defaultOrder) {
    // TODO: Add another option to pick from existing workouts
    return TextButton(
        onPressed: () {
          addExercise(day, defaultOrder);
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

  /// Workouts list is intended to be constrained for the day
  Widget buildDay(List<Workout> workouts, int day) {
    // Cast is necessary, otherwise it auto assigns List<Widget> to
    // List<WorkoutCard> and falls over when adding the button
    List<Widget> workoutList = workouts
        .map((w) => WorkoutCard(
              allowDelete: true,
              workout: w,
              rebuildCallback: () => setState(() {}),
            ) as Widget)
        .toList();
    workoutList.add(buildAddExercise(day, workouts.length + 1));

    return ExpansionTile(
        title: Text('Day ' + day.toString()),
        initiallyExpanded: true,
        children: [
          SizedBox(
              height: 240,
              child: ListView(
                controller: _scrollController,
                children: workoutList,
              )),
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
