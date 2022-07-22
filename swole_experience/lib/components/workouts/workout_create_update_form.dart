import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/service/workout_service.dart';
import 'package:swole_experience/components/AlertSnackBar.dart';
import 'package:swole_experience/model/workout.dart';

class WorkoutCreateUpdateForm extends StatefulWidget {
  const WorkoutCreateUpdateForm({
    Key? key,
    this.weight,
    required this.rebuildCallback,
  }) : super(key: key);

  final Workout? weight;
  final Function rebuildCallback;

  @override
  State<WorkoutCreateUpdateForm> createState() => _WorkoutCreateUpdateFormState();
}

class _WorkoutCreateUpdateFormState extends State<WorkoutCreateUpdateForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Logger logger = Logger();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void createWorkout() {
    if (_weightController.value.text.isNotEmpty ||
        _dateController.value.text.isNotEmpty) {

      Workout workout = Workout(day: 1, id: '', dayOrder: 0, sets: 4, name: 'Bench Press', reps: 8, weight: 225);

      WorkoutService.svc.createWorkout(workout).onError((error, stackTrace) {
        logger.e("Error creating workout $error", stackTrace);
        const AlertSnackBar(
          message: 'Unable to create workout.',
          state: SnackBarState.failure,
        ).alert(context);
        return 0;
      }).then((res) => res != 0 ? widget.rebuildCallback(context) : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[

          ],
        ));
  }
}
