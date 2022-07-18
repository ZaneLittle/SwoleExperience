import 'package:flutter/material.dart';

import 'package:swole_experience/model/workout.dart';

class WorkoutCard extends StatefulWidget {
  const WorkoutCard({
    Key? key,
    this.context,
    required this.workout,
  }) : super(key: key);

  final BuildContext? context;
  final Workout workout;

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
        ? (86 + ((widget.workout.notes!.length / 52).truncate() + 1) * 18)
        : 86;
  }

  Widget buildList() {
    Workout w = widget.workout; // alias because I'm lazy
    return ListView(
      controller: _scrollController,
      children: [
        Card(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(w.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
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
            hasNote()
                ? Card(
                    color: const Color(0x33ffffff),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(widget.workout.notes!,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic)))))
                : Container()
          ]),
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _workoutListKey,
      height: getHeight(),
      child: buildList(),
    );
  }
}
