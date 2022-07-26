import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/service/workout_service.dart';
import 'package:swole_experience/components/AlertSnackBar.dart';
import 'package:swole_experience/model/workout.dart';
import 'package:swole_experience/util/util.dart';
import 'package:swole_experience/util/validator.dart';

class WorkoutCreateUpdateForm extends StatefulWidget {
  const WorkoutCreateUpdateForm({
    Key? key,
    this.workout,
    required this.day,
    required this.defaultOrder,
    required this.rebuildCallback,
  }) : super(key: key);

  final Workout? workout;
  final int day;
  final int defaultOrder;
  final Function rebuildCallback;

  @override
  State<WorkoutCreateUpdateForm> createState() =>
      _WorkoutCreateUpdateFormState();
}

// TODO: leaves it scrolled down after editing note
class _WorkoutCreateUpdateFormState extends State<WorkoutCreateUpdateForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<_WorkoutCreateUpdateFormState> _notesFieldKey =
      GlobalKey<_WorkoutCreateUpdateFormState>();
  final GlobalKey<_WorkoutCreateUpdateFormState> _nameFieldKey =
      GlobalKey<_WorkoutCreateUpdateFormState>();
  final Logger logger = Logger();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();

  void createWorkout() {
    Workout workout = Workout(
      day: int.tryParse(_dayController.value.text) ?? widget.day,
      id: Random().nextInt(9999).toString(),
      dayOrder:
          int.tryParse(_orderController.value.text) ?? widget.defaultOrder,
      name: _nameController.value.text,
      sets: int.parse(_setsController.value.text),
      reps: int.parse(_repsController.value.text),
      weight: double.parse(_weightController.value.text),
      notes: _notesController.value.text,
    );

    WorkoutService.svc.createWorkout(workout).onError((error, stackTrace) {
      return handleSaveError('create', error, stackTrace);
    }).then((res) => res != 0 ? widget.rebuildCallback(workout) : null);
  }

  void updateWorkout() {
    if (widget.workout != null) {
      Workout workout = Workout(
        day: int.tryParse(_dayController.value.text) ?? widget.day,
        id: widget.workout!.id,
        dayOrder:
            int.tryParse(_orderController.value.text) ?? widget.defaultOrder,
        name: _nameController.value.text.isNotEmpty
            ? _nameController.value.text
            : widget.workout!.name,
        sets: int.tryParse(_setsController.value.text) ?? widget.workout!.sets,
        reps: int.tryParse(_repsController.value.text) ?? widget.workout!.reps,
        weight: double.tryParse(_weightController.value.text) ??
            widget.workout!.weight,
        notes: _notesController.value.text.isNotEmpty
            ? _notesController.value.text
            : widget.workout?.notes,
      );

      WorkoutService.svc.updateWorkout(workout).onError((error, stackTrace) {
        return handleSaveError('update', error, stackTrace);
      }).then((res) => res != 0 ? widget.rebuildCallback(workout) : null);
    } else {
      logger.e(
          'Error: updating but no workout on stack - should not be possible');
      handleSaveError('update', null, null);
    }
  }

  bool isAnyChanged() {
    return _nameController.value.text.isNotEmpty ||
        _orderController.value.text.isNotEmpty ||
        _weightController.value.text.isNotEmpty ||
        _setsController.value.text.isNotEmpty ||
        _repsController.value.text.isNotEmpty ||
        _notesController.value.text.isNotEmpty;
  }

  int handleSaveError(String operation, Object? error, StackTrace? stackTrace) {
    logger.e("Error ${operation}ing workout $error", stackTrace);
    const AlertSnackBar(
      message: "Unable to update or create the workout.",
      state: SnackBarState.failure,
    ).alert(context);
    return 0;
  }

  void save() {
    widget.workout != null ? updateWorkout() : createWorkout();
  }

  ///                               ELEMENTS                                 ///

  Widget buildNameField() {
    return Expanded(
        child: SizedBox(
            key: _nameFieldKey,
            height: 84,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 24, bottom: 24, left: 32, right: 12),
              child: TextFormField(
                  controller: _nameController,
                  validator: (String? value) => Validator.stringValidator(value,
                      defaultValue: widget.workout?.name),
                  decoration: InputDecoration(
                      hintText: widget.workout?.name ?? 'Name')),
            )));
  }

  Widget buildOrderField() {
    return SizedBox(
        height: 84,
        width: 96,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 24, left: 12, right: 32),
          child: TextFormField(
              controller: _orderController,
              validator: (String? value) =>
                  Validator.intValidatorNullAllowed(value),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(
                  hintText: widget.workout?.dayOrder.toString() ?? 'Order')),
        ));
  }

  Widget buildWeightField() {
    return Expanded(
        child: SizedBox(
            height: 84,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 24, bottom: 24, left: 32, right: 12),
              child: TextFormField(
                  controller: _weightController,
                  validator: (String? value) => Validator.doubleValidator(value,
                      defaultValue: widget.workout?.weight),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      hintText: widget.workout?.weight.toString() ?? 'Weight')),
            )));
  }

  Widget buildSetsField() {
    return Expanded(
        child: SizedBox(
            height: 84,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 24, bottom: 24, left: 12, right: 12),
              child: TextFormField(
                  controller: _setsController,
                  validator: (String? value) => Validator.intValidator(value,
                      defaultValue: widget.workout?.sets),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  decoration: InputDecoration(
                      hintText: widget.workout?.sets.toString() ?? 'Sets')),
            )));
  }

  Widget buildRepsField() {
    return Expanded(
        child: SizedBox(
            height: 84,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 24, bottom: 24, left: 12, right: 32),
              child: TextFormField(
                  controller: _repsController,
                  validator: (String? value) => Validator.intValidator(value,
                      defaultValue: widget.workout?.reps),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  decoration: InputDecoration(
                      hintText: widget.workout?.reps.toString() ?? 'Reps')),
            )));
  }

  Widget buildNotesField() {
    return SizedBox(
        key: _notesFieldKey,
        height: 240,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 24, left: 32, right: 32),
          child: TextFormField(
            controller: _notesController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: widget.workout?.notes ?? 'Notes'),
            onTap: () => Util().scrollToSelectedContext(_notesFieldKey),
          ),
        ));
  }

  Widget buildConfirmCancel() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      IconButton(
        iconSize: 32,
        icon: const Icon(Icons.cancel),
        onPressed: () {
          Navigator.of(context).pop();
          widget.rebuildCallback(widget.workout);
        },
      ),
      IconButton(
        iconSize: 32,
        icon: Icon(
            widget.workout == null ? Icons.add_circle : Icons.check_circle,
            color: CommonStyles.primaryColour),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            save();
            Navigator.of(context).pop();
          }
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            Row(children: [
              buildNameField(),
              buildOrderField(),
            ]),
            Row(children: [
              buildWeightField(),
              buildSetsField(),
              buildRepsField(),
            ]),
            buildNotesField(),
            buildConfirmCancel(),
            SizedBox(height: MediaQuery.of(context).size.height * .34)
          ],
        ));
  }
}
