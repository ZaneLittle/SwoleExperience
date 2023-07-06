import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/components/workouts/trends/workout_history_chart.dart';
import 'package:swole_experience/components/workouts/trends/workout_history_list.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout_history.dart';
import 'package:swole_experience/service/db/favourite_workout_service.dart';

import 'package:swole_experience/service/db/workout_history_service.dart';

class Trends extends StatefulWidget {
  const Trends({Key? key}) : super(key: key);

  @override
  State<Trends> createState() => _TrendsState();
}

class _TrendsState extends State<Trends> {
  Map<String, List<WorkoutHistory>> _workoutMap = {};
  List<String> _favourites = [];
  String? _selectedWorkout;

  bool get hasWorkouts => _workoutMap[_selectedWorkout]?.isNotEmpty ?? false;

  bool get selectedIsFavourite => _favourites.contains(_selectedWorkout);

  void setFavourite(String workoutId) {
    FavouriteWorkoutService.svc.addFavourite(workoutId);
    setState(() {
      _favourites.add(workoutId);
    });
  }

  void removeFavourite(String workoutId) {
    FavouriteWorkoutService.svc.removeFavourite(workoutId);
    setState(() {
      _favourites.remove(workoutId);
    });
  }

  Widget buildWorkoutItem(String name, String id) {
    bool showStar = _favourites.contains(id);

    return SizedBox(width: 258, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name),
            showStar
                ? const Icon(Icons.star, color: Colors.amberAccent, size: 12)
                : Container(),
          ]));
  }

  // TODO: move this down to separate element / force it to not rebuild
  Widget buildSelectionRow() {
    List<String> workoutIds = _workoutMap.keys.toList();
    workoutIds.sort((a, b) {
      if (_favourites.contains(a) && !_favourites.contains(b)) {
        return -1;
      } else if (!_favourites.contains(a) && _favourites.contains(b)) {
        return 1;
      }
      return _workoutMap[a]!.first.name.compareTo(_workoutMap[b]!.first.name);
    });

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.only(right: 12, top: 12),
        child: IconButton(
          icon: selectedIsFavourite
              ? const Icon(Icons.star, color: Colors.amberAccent)
              : const Icon(Icons.star_outline),
          onPressed: () => {
            if (_selectedWorkout != null)
              {
                selectedIsFavourite
                    ? removeFavourite(_selectedWorkout!)
                    : setFavourite(_selectedWorkout!)
              }
          },
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 12, top: 12),
          child: DropdownButton(
              value: _selectedWorkout,
              items: workoutIds
                  .map((id) => DropdownMenuItem(
                      child: buildWorkoutItem(_workoutMap[id]!.first.name, id),
                      value: id))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWorkout = value.toString();
                });
              })),
    ]);
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
              FavouriteWorkoutService.svc.getFavourites(),
            ]),
            builder: (BuildContext context,
                AsyncSnapshot<List<dynamic>> initSnapshot) {
              if (initSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              } else {
                if (initSnapshot.data?.first != null) {
                  _favourites = initSnapshot.requireData[1];
                  _workoutMap = initSnapshot.requireData[0];
                  _selectedWorkout ??= _favourites.isNotEmpty &&
                          _workoutMap.keys.contains(_favourites.first)
                      ? _favourites.first
                      : _workoutMap.keys.first;

                  return Column(
                    children: [
                      buildSelectionRow(),
                      hasWorkouts
                          ? WorkoutHistoryChart(
                              workouts: _workoutMap[_selectedWorkout]!)
                          : Container(),
                      hasWorkouts
                          ? WorkoutHistoryList(
                              context: context,
                              workouts: _workoutMap[_selectedWorkout]!)
                          : Container(),
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
