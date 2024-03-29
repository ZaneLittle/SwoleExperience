import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/components/AlertSnackBar.dart';
import 'package:swole_experience/components/workouts/workout_card.dart';
import 'package:swole_experience/components/workouts/workout_create_update_form.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/toggles.dart';
import 'package:swole_experience/model/workout_day.dart';
import 'package:swole_experience/service/preference_service.dart';
import 'package:swole_experience/service/workout_service.dart';
import 'package:swole_experience/util/util.dart';

class WorkoutsConfigure extends StatefulWidget {
  const WorkoutsConfigure({Key? key, this.context, this.freshBuild = false})
      : super(key: key);

  final BuildContext? context;
  final bool freshBuild;

  @override
  State<WorkoutsConfigure> createState() {
    return _WorkoutsConfigureState();
  }
}

class _WorkoutsConfigureState extends State<WorkoutsConfigure> {
  final GlobalKey<_WorkoutsConfigureState> _workoutsConfigureKey =
      GlobalKey<_WorkoutsConfigureState>();
  final ScrollController _scrollController = ScrollController();
  final Logger logger = Logger();

  bool shouldFetch = false;
  bool isSupersetsEnabled = Toggles.supersets;
  bool isAlternativesEnabled = Toggles.alternativeWorkouts;
  bool isProgressionHelperEnabled = Toggles.progressionHelper;
  Map<int, List<WorkoutDay>> workoutMap = {
    1: [],
  };

  @override
  void initState() {
    super.initState();
    shouldFetch = widget.freshBuild;
  }

  ///                         Processing                                    ///

  void initWorkoutMap(List<WorkoutDay> workouts) {
    for (int key in workoutMap.keys) {
      workoutMap[key] = [];
    }

    Map<int, List<WorkoutDay>> _workoutMap = Util().getWorkoutDays(workouts);
    for (int day = 1; day <= _workoutMap.keys.length; day++) {
      workoutMap[day] = _workoutMap[day]!;
    }
  }

  void rebuild(
      {WorkoutDay? workout, bool delete = false, bool update = false}) {
    setState(() {
      if (workout != null && (delete || update)) {
        workoutMap[workout.day]?.removeAt(workout.dayOrder);
      }
      if (workout != null && !delete) {
        // TODO: this adding logic is not right - not adding at the right spot
        (workoutMap[workout.day] != null)
            ? workoutMap[workout.day]!.insert(workout.dayOrder, workout)
            : workoutMap[workout.day] = [workout];
      }

      shouldFetch = false;
    });
  }

  void addDay() {
    setState(() {
      workoutMap[workoutMap.keys.last + 1] = [];
      shouldFetch = false;
    });
  }

  void addExercise(int day, int defaultOrder, List<WorkoutDay> workouts) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return SizedBox(
              child: WorkoutCreateUpdateForm(
            day: day,
            defaultOrder: defaultOrder,
            rebuildCallback: rebuild,
            workoutsInDay: workouts,
            isAlternativesEnabled: isAlternativesEnabled,
            isSupersetsEnabled: isSupersetsEnabled,
            isProgressionHelperEnabled: isProgressionHelperEnabled,
          ));
        });
  }

  void removeEmptyDays() {
    bool popupHasBeenDisplayed = false;
    for (int day in workoutMap.keys) {
      if (workoutMap[day] == null || workoutMap[day]!.isEmpty) {
        // Find next non-empty day, if none, exit
        bool found = false;
        for (int nextDay = day + 1;
            nextDay <= workoutMap.keys.length;
            nextDay++) {
          if (workoutMap[nextDay] != null && workoutMap[nextDay]!.isNotEmpty) {
            if (!popupHasBeenDisplayed) {
              const AlertSnackBar(
                message: 'Rearranging your days!',
                state: SnackBarState.info,
              ).alert(context);
            }

            // Move next set of workouts to this day
            workoutMap[day] = workoutMap[nextDay]!;
            workoutMap[nextDay] = [];

            // Update the day for each of the records
            for (WorkoutDay workout in workoutMap[day]!) {
              WorkoutDay updatedWorkout = WorkoutDay(
                id: workout.id,
                day: day,
                dayOrder: workout.dayOrder,
                name: workout.name,
                weight: workout.weight,
                sets: workout.sets,
                reps: workout.reps,
                notes: workout.notes,
              );
              WorkoutService.svc.updateWorkout(updatedWorkout);
            }

            break;
          }
        }
        if (!found) {
          // we don't have any more workouts in the map, the end will be pruned
          break;
        }
      }
    }
  }

  void reorderAllDays() {
    for (int day in workoutMap.keys) {
      reorderDay(day);
    }
  }

  /// Update the order of each workout in the workout map of a given day based on the order it appears in the list
  void reorderDay(int day) {
    for (int i = 0; i < workoutMap[day]!.length; i++) {
      WorkoutDay w = workoutMap[day]![i];
      if (w.dayOrder != i) {
        WorkoutDay newW = w.copy(dayOrder: i);
        workoutMap[day]![i] = newW;
        WorkoutService.svc.updateWorkout(workoutMap[day]![i].copy(dayOrder: i));
      }
    }
  }

  ///                                 ELEMENTS                              ///

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

  Widget buildAddExercise(
      int day, int defaultOrder, List<WorkoutDay> workouts) {
    // TODO: Add another option to pick from existing workouts
    return TextButton(
        key: Key('addButton$day'),
        onPressed: () {
          addExercise(day, defaultOrder, workouts);
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
  Widget buildDay(List<WorkoutDay> workouts, int day) {
    // Cast is necessary, otherwise it auto assigns List<Widget> to
    // List<WorkoutCard> and falls over when adding the button
    List<Widget> workoutList = workouts.map((w) {
      return WorkoutCard(
        key: Key("_workoutCard${w.id}_${Random().nextInt(9999).toString()}"),
        allowDelete: true,
        allowUpdate: true,
        workout: w,
        rebuildCallback: rebuild,
        workoutsInDay: workouts,
        isAlternativesEnabled: isAlternativesEnabled,
        isSupersetsEnabled: isSupersetsEnabled,
        isProgressionHelperEnabled: isProgressionHelperEnabled,
      ) as Widget;
    }).toList();
    workoutList.add(buildAddExercise(day, workouts.length, workouts));
    return ExpansionTile(
        title: Text('Day ' + day.toString()),
        initiallyExpanded: true,
        children: [
          SizedBox(
              height: 240,
              child: ReorderableListView(
                  children: workoutList,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      if (newIndex >= workoutMap[day]!.length) {
                        newIndex = workoutMap[day]!.length - 1;
                      }

                      WorkoutDay w = workoutMap[day]!.removeAt(oldIndex);
                      workoutMap[day]!.insert(newIndex, w);

                      reorderDay(day);

                      shouldFetch = false;
                    });
                  })),
        ]);
  }

  Widget buildDays() {
    List<int> dayList = workoutMap.keys.toList();
    List<Widget> dayWidgetList =
        dayList.map((day) => buildDay(workoutMap[day]!, day)).toList();
    dayWidgetList.add(buildAddDay());

    return SizedBox(
        height: MediaQuery.of(context).size.height - 80,
        child:
            ListView(controller: _scrollController, children: dayWidgetList));
  }

  @override
  Widget build(BuildContext context) {
    if (shouldFetch) {
      return Scaffold(
          key: _workoutsConfigureKey,
          appBar: AppBar(
            backgroundColor: CommonStyles.primaryDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 32,
              onPressed: () {
                removeEmptyDays();
                reorderAllDays();
                Navigator.pop(context);
                setState(() {});
              },
            ),
            title: const Text('Configure workouts'),
          ),
          body: FutureBuilder<List<dynamic>>(
              future: Future.wait([
                WorkoutService.svc.getWorkouts(),
                PreferenceService.svc
                    .isToggleEnabled(Toggles.alternativeWorkoutsKey),
                PreferenceService.svc.isToggleEnabled(Toggles.supersetsKey),
                PreferenceService.svc
                    .isToggleEnabled(Toggles.progressionHelperKey),
              ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text('Loading...'));
                } else {
                  isAlternativesEnabled = snapshot.requireData[1];
                  isSupersetsEnabled = snapshot.requireData[2];
                  isProgressionHelperEnabled = snapshot.requireData[3];
                  List<WorkoutDay> workouts =
                      snapshot.requireData[0] as List<WorkoutDay>;
                  initWorkoutMap(workouts);
                  shouldFetch = false;

                  return SizedBox(
                      child: ListView(
                          controller: _scrollController,
                          children: <Widget>[
                        buildDays(),
                      ]));
                }
              }));
    } else {
      return Scaffold(
          key: _workoutsConfigureKey,
          appBar: AppBar(
            backgroundColor: CommonStyles.primaryDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 32,
              onPressed: () {
                removeEmptyDays();
                reorderAllDays();
                Navigator.pop(context);
                setState(() {});
              },
            ),
            title: const Text('Configure workouts'),
          ),
          body: SizedBox(
              child: ListView(controller: _scrollController, children: <Widget>[
            buildDays(),
          ])));
    }
  }
}
