import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workout_create_update_form.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/service/workout_service.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard({
    Key? key,
    this.context,
    this.allowDelete = false,
    required this.workout,
    required this.rebuildCallback,
  }) : super(key: key);

  final bool allowDelete;
  final BuildContext? context;
  final Workout workout;
  final Function rebuildCallback;

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  final GlobalKey<_WorkoutCardState> _workoutListKey =
      GlobalKey<_WorkoutCardState>();

  final ScrollController _scrollController = ScrollController();

  bool hasNote() {
    return widget.workout.notes != null && widget.workout.notes != '';
  }

  double getHeight() {
    return hasNote()
        ? getNoteHeight(widget.workout.notes!) + 80
        : 80;
  }

  /// Scale notes to a max of 3 lines
  double getNoteHeight(String notes) {
    return (notes.length > 60 || notes.contains('\n')) ? 62 : 38;
  }

  Widget buildList(Workout? workout) {
    Workout w = workout ?? widget.workout;
    return Dismissible(
        onDismissed: (DismissDirection direction) {
          if (direction.name == 'startToEnd' && widget.allowDelete) {
            // TODO: do we just set to day 0 instead of deleting?
            WorkoutService.svc.removeWorkout(widget.workout.id);
            widget.rebuildCallback();
          } else if (direction.name == 'endToStart') {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext ctx) {
                  return SizedBox(
                      child: WorkoutCreateUpdateForm(
                          day: w.day,
                          defaultOrder: w.dayOrder,
                          workout: w,
                          rebuildCallback: (Workout workout) {
                            widget.rebuildCallback();
                          }));
                });
          } else {
            widget.rebuildCallback();
            //TODO: Mark as done instead?
          }
        },
        key: ValueKey("_workoutCard${widget.workout.id}"),
        background: Row(children: [
          widget.allowDelete ? Expanded(
              child: Container(
                  color: Colors.red,
                  child: Align(alignment:Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18),
                          child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.close),
                        Text('Delete'),
                  ]))))) : Container(),
          Expanded(
              child: Container(
                  color: CommonStyles.primaryColour,
                  child: Align(alignment:Alignment.centerRight,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.mode_edit),
                                Text('Update'),
                              ]))))),
        ]),
        child: SizedBox(
                height: getHeight(),
                width: MediaQuery.of(context).size.width,
                child: Card(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Column(children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(w.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('Weight: '),
                              Text(w.weight.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Sets: '),
                              Text(w.sets.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Reps: '),
                              Text(w.reps.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ]),
                    hasNote()
                        ? Card(
                            color: const Color(0x33ffffff),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    getNoteHeight(widget.workout.notes!) - 7,
                                child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ListView(
                                        controller: _scrollController,
                                        children: [
                                          Text(widget.workout.notes!,
                                              style: const TextStyle(
                                                  fontStyle: FontStyle.italic))
                                        ]))))
                        : Container()
                  ]),
                ))));
  }

  @override
  Widget build(BuildContext context, {Workout? rebuildWorkout}) {
    return SizedBox(
        key: _workoutListKey, height: getHeight(), child: buildList(rebuildWorkout));
  }
}
