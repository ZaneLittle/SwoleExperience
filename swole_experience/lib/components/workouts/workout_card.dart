import 'dart:math';

import 'package:flutter/material.dart';

import 'package:swole_experience/components/workouts/workout_create_update_form.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/toggles.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/model/workout_day.dart';
import 'package:swole_experience/service/db/workout_service.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard({
    Key? key,
    this.context,
    this.allowDelete = false,
    this.allowUpdate = false,
    required this.workout,
    required this.rebuildCallback,
    this.workoutsInDay,
    this.alternatives,
    this.supersets,
    this.isSupersetsEnabled = Toggles.supersets,
    this.isAlternativesEnabled = Toggles.alternativeWorkouts,
    this.isProgressionHelperEnabled = Toggles.progressionHelper,
  }) : super(key: key);

  final bool allowDelete;
  final bool allowUpdate;
  final BuildContext? context;
  final Workout workout;
  final Function rebuildCallback;
  final List<WorkoutDay>? workoutsInDay;
  final List<Workout>? alternatives;
  final List<Workout>? supersets;
  final bool isSupersetsEnabled;
  final bool isAlternativesEnabled;
  final bool isProgressionHelperEnabled;

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  final GlobalKey<_WorkoutCardState> _workoutListKey =
      GlobalKey<_WorkoutCardState>();

  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  double getHeight() {
    double baseHeight = 96;
    double maxNoteHeight = getMaxNoteHeight();
    double supersetHeight = getSupersetHeight();

    return baseHeight + maxNoteHeight + supersetHeight;
  }

  double getSupersetHeight() {
    if (widget.supersets == null) {
      return 0;
    }

    return widget.supersets!.length * 62;
  }

  double getMaxNoteHeight() {
    double maxNoteHeight = 0;

    List<String> notes = [];
    String? mainNote = getMainNote();
    if (mainNote != null) {
      notes.add(mainNote);
    }
    notes.addAll(
        widget.alternatives?.where((w) => w.hasNote()).map((w) => w.notes!) ??
            []);

    for (String note in notes) {
      if (note.trim().length > 60 || note.trim().contains('\n')) {
        return 62;
      } else if (note.trim().isNotEmpty) {
        maxNoteHeight = 38;
      }
    }
    return maxNoteHeight;
  }

  /// Scale notes to a max of 3 lines
  double getNoteHeight(String notes) {
    return (notes.length > 60 || notes.contains('\n')) ? 62 : 38;
  }

  /// The "main note" is comprised of the primary workout's note with the notes
  /// of the supersets appended to it
  String? getMainNote() {
    String? note = widget.workout.notes;
    for (Workout superset in widget.supersets ?? []) {
      if (note != null) {
        // TODO: no string concat - is this the best way of doing that?
        note += "\n${superset.notes}";
      } else {
        note = superset.notes;
      }
    }
    return note;
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

  void showUpdateModal(Workout w) {
    if (w is WorkoutDay) {
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
              isAlternativesEnabled: widget.isAlternativesEnabled,
              isSupersetsEnabled: widget.isSupersetsEnabled,
              isProgressionHelperEnabled: widget.isProgressionHelperEnabled,
            ));
          });
    }
  }

  void onDismissed(DismissDirection direction, WorkoutDay w) {
    if (direction == DismissDirection.startToEnd && widget.allowDelete) {
      // TODO: do we just set to day 0 instead of deleting?
      WorkoutService.svc.removeWorkout(widget.workout.id);
      widget.rebuildCallback(workout: w, delete: true);
    } else if (direction == DismissDirection.endToStart) {
      showUpdateModal(w);
    } else {
      widget.rebuildCallback(workout: w);
    }
  }

  List<Widget> buildCardList(Workout w) {
    List<Widget> cards = [
      buildCard(w,
          hasNext: widget.alternatives?.isNotEmpty ?? false, isMain: true)
    ];
    int len = widget.alternatives?.length ?? 0;
    for (int i = 0; i < len; i++) {
      cards.add(buildCard(widget.alternatives![i],
          hasPrevious: true, hasNext: i < len - 1));
    }
    return cards;
  }

  Widget buildAltNextIndicator() {
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

  Widget buildNotes(Workout w, {bool isMain = false}) {
    String? note = "";
    if (isMain) {
      note = getMainNote();
    } else {
      note = w.notes;
    }

    if (note?.isEmpty ?? true) {
      return Container();
    } else {
      return Card(
          color: CommonStyles.cardBackground,
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: getNoteHeight(w.notes!) - 7,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView(controller: _scrollController, children: [
                    Text(w.notes!,
                        style: const TextStyle(fontStyle: FontStyle.italic))
                  ]))));
    }
  }

  List<Widget> buildSupersets() {
    if (widget.supersets?.isEmpty ?? true) {
      return [Container()];
    }

    List<Widget> supersetWidgets = [];
    for (Workout superset in widget.supersets!) {
      supersetWidgets.add(buildInfoSection(superset, false, false));
    }
    return supersetWidgets;
  }

  Widget buildInfoSection(Workout w, bool hasPrevious, bool hasNext) {
    return GestureDetector(
        onLongPress: () => showUpdateModal(w),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: buildNameRow(w,
                      hasPrevious: hasPrevious, hasNext: hasNext)),
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
            ])));
  }

  Widget buildCard(
    Workout w, {
    bool hasPrevious = false,
    bool hasNext = false,
    bool isMain = false,
  }) {
    List<Widget> cardBody = [];
    cardBody.add(buildInfoSection(w, hasPrevious, hasNext));
    (isMain) ? cardBody.addAll(buildSupersets()) : null;
    cardBody.add(buildNotes(w));

    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(children: cardBody),
        )));
  }

  Widget buildList(Workout w) {
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
        ));
  }

  @override
  Widget build(BuildContext context, {WorkoutDay? rebuildWorkout}) {
    Workout workout = rebuildWorkout ?? widget.workout;
    return SizedBox(
        key: _workoutListKey,
        height: getHeight(),
        width: MediaQuery.of(context).size.width,
        child: buildList(workout));
  }
}
