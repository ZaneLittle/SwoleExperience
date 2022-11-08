import 'dart:math';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workout_create_update_form.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/model/workout_day.dart';
import 'package:swole_experience/service/workout_service.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard(
      {Key? key,
      this.context,
      this.allowDelete = false,
      this.allowUpdate = false,
      required this.workout,
      required this.rebuildCallback,
      this.workoutsInDay,
      this.alternatives})
      : super(key: key);

  final bool allowDelete;
  final bool allowUpdate;
  final BuildContext? context;
  final Workout workout;
  final Function rebuildCallback;
  final List<WorkoutDay>? workoutsInDay;
  final List<Workout>? alternatives;

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  final GlobalKey<_WorkoutCardState> _workoutListKey =
      GlobalKey<_WorkoutCardState>();

  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  double getHeight() {
    List<Workout> workouts = [widget.workout];
    workouts.addAll(widget.alternatives ?? []);
    bool hasNote = workouts.where((w) => w.hasNote()).isNotEmpty;
    return hasNote ? getNoteHeight(widget.workout.notes!) + 80 : 80;
  }

  /// Scale notes to a max of 3 lines
  double getNoteHeight(String notes) {
    return (notes.length > 60 || notes.contains('\n')) ? 62 : 38;
  }

  DismissDirection getDismissDirection() {
    if (widget.allowDelete && widget.allowUpdate) {
      return DismissDirection.horizontal;
    } else if (widget.allowDelete && !widget.allowUpdate) {
      return DismissDirection.startToEnd;
    } else if (!widget.allowDelete && widget.allowUpdate) {
      return DismissDirection.endToStart;
    } else {
      return DismissDirection.none;
    }
  }

  void onDismissed(DismissDirection direction, WorkoutDay w) {
    if (direction == DismissDirection.startToEnd && widget.allowDelete) {
      // TODO: do we just set to day 0 instead of deleting?
      WorkoutService.svc.removeWorkout(widget.workout.id);
      widget.rebuildCallback(workout: w, delete: true);
    } else if (direction == DismissDirection.endToStart) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext ctx) {
            return SizedBox(
                child: WorkoutCreateUpdateForm(
              day: w.day,
              defaultOrder: w.dayOrder,
              workout: w,
              rebuildCallback: (
                  {WorkoutDay? workout,
                  bool delete = false,
                  bool update = false}) {
                widget.rebuildCallback(
                    workout: workout, delete: delete, update: update);
              },
              workoutsInDay: widget.workoutsInDay,
            ));
          });
    } else {
      widget.rebuildCallback(workout: w);
      //TODO: Mark as done?
    }
  }

  List<Widget> buildCardList(Workout w) {
    List<Widget> cards = [
      buildCard(w, hasNext: widget.alternatives?.isNotEmpty ?? false)
    ];
    int len = widget.alternatives?.length ?? 0;
    for (int i = 0; i < len; i++) {
      cards.add(buildCard(widget.alternatives![i],
          hasPrevious: true, hasNext: i < len - 1));
    }
    return cards;
  }

  Widget buildAltNextIndicator() {
    // return const Card(color: CommonStyles.primaryColour, child: Text(">"));
    return const Icon(Icons.chevron_right,
        color: CommonStyles.primaryColour, size: 18);
  }

  Widget buildAltPreviousIndicator() {
    return const Icon(Icons.chevron_left,
        color: CommonStyles.primaryColour, size: 18);
  }

  Widget buildNameRow(Workout w,
      {bool hasPrevious = false, bool hasNext = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        hasPrevious ? buildAltPreviousIndicator() : const SizedBox(width: 18),
        Text(w.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        hasNext ? buildAltNextIndicator() : const SizedBox(width: 18),
      ],
    );
  }

  Widget buildCard(Workout w,
      {bool hasPrevious = false, bool hasNext = false}) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: buildNameRow(w, hasPrevious: hasPrevious, hasNext: hasNext)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  const Text('Weight: '),
                  Text(w.weight.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
              Row(
                children: [
                  const Text('Sets: '),
                  Text(w.sets.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
              Row(
                children: [
                  const Text('Reps: '),
                  Text(w.reps.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ]),
            w.hasNote()
                ? Card(
                    color: const Color(0x33ffffff),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: getNoteHeight(widget.workout.notes!) - 7,
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
        )));
  }

  Widget buildList(WorkoutDay? workout) {
    Workout w = workout ?? widget.workout;
    DismissDirection dismissDirection = getDismissDirection();

    return Dismissible(
        onDismissed: (DismissDirection direction) =>
            onDismissed(direction, w as WorkoutDay),
        key: ValueKey(
            "_workoutCard${widget.workout.id}_${Random().nextInt(9999).toString()}"),
        resizeDuration: const Duration(milliseconds: 50),
        direction: dismissDirection,
        background: widget.allowDelete
            ? Container(
                color: Colors.red,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.close),
                              Text('Delete'),
                            ]))))
            : Container(),
        secondaryBackground: Container(
            color: CommonStyles.primaryColour,
            child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.mode_edit),
                          Text('Update'),
                        ])))),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              children: buildCardList(w)),
          // buildCard(w)
        ));
  }

  @override
  Widget build(BuildContext context, {WorkoutDay? rebuildWorkout}) {
    return SizedBox(
        key: _workoutListKey,
        height: getHeight(),
        width: MediaQuery.of(context).size.width,
        child: buildList(rebuildWorkout));
  }
}
