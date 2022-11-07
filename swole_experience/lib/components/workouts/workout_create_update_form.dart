import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/constants/toggles.dart';
import 'package:swole_experience/service/workout_service.dart';
import 'package:swole_experience/components/AlertSnackBar.dart';
import 'package:swole_experience/model/workout_day.dart';
import 'package:swole_experience/util/util.dart';
import 'package:swole_experience/util/validator.dart';

class WorkoutCreateUpdateForm extends StatefulWidget {
  const WorkoutCreateUpdateForm({
    Key? key,
    this.workout,
    required this.day,
    required this.defaultOrder,
    required this.rebuildCallback,
    this.workoutsInDay,
  }) : super(key: key);

  final WorkoutDay? workout;
  final int day;
  final int defaultOrder;
  final Function rebuildCallback;
  final List<WorkoutDay>? workoutsInDay;

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
  final GlobalKey<_WorkoutCreateUpdateFormState> _altDropdownKey =
      GlobalKey<_WorkoutCreateUpdateFormState>();
  final Logger logger = Logger();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _altScrollController = ScrollController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  String? _alternativeId;
  String? _supersetId;

  void createWorkout() {
    WorkoutDay workout = WorkoutDay(
      day: int.tryParse(_dayController.value.text) ?? widget.day,
      id: Random().nextInt(9999).toString(),
      dayOrder: widget.defaultOrder,
      name: _nameController.value.text,
      sets: int.parse(_setsController.value.text),
      reps: int.parse(_repsController.value.text),
      weight: double.parse(_weightController.value.text),
      notes: _notesController.value.text,
      altParentId: _alternativeId,
    );

    WorkoutService.svc.createWorkout(workout).onError((error, stackTrace) {
      return handleSaveError('create', error, stackTrace);
    }).then(
        (res) => res != 0 ? widget.rebuildCallback(workout: workout) : null);
  }

  void updateWorkout() {
    if (widget.workout != null) {
      WorkoutDay workout = WorkoutDay(
        day: int.tryParse(_dayController.value.text) ?? widget.day,
        id: widget.workout!.id,
        dayOrder: widget.defaultOrder,
        name: _nameController.value.text.isNotEmpty
            ? _nameController.value.text
            : widget.workout!.name,
        sets: int.tryParse(_setsController.value.text) ?? widget.workout!.sets,
        reps: int.tryParse(_repsController.value.text) ?? widget.workout!.reps,
        weight: double.tryParse(_weightController.value.text) ??
            widget.workout!.weight,
        notes: _notesController.value.text,
        altParentId: _alternativeId,
      );

      WorkoutService.svc.updateWorkout(workout).onError((error, stackTrace) {
        return handleSaveError('update', error, stackTrace);
      }).then((res) {
        res != 0
            ? widget.rebuildCallback(workout: workout, update: true)
            : null;
      });
    } else {
      logger.e(
          'Error: updating but no workout on stack - should not be possible');
      handleSaveError('update', null, null);
    }
  }

  bool isAnyChanged() {
    return _nameController.value.text.isNotEmpty ||
        _weightController.value.text.isNotEmpty ||
        _setsController.value.text.isNotEmpty ||
        _repsController.value.text.isNotEmpty ||
        _notesController.value.text.isNotEmpty;
  }

  int handleSaveError(String operation, Object? error, StackTrace? stackTrace) {
    logger.e("Error ${operation}ing workout: $error", error, stackTrace);
    const AlertSnackBar(
      message: "Unable to update or create the workout.",
      state: SnackBarState.failure,
    ).alert(context);
    return 0;
  }

  void save() {
    widget.workout != null ? updateWorkout() : createWorkout();
  }

  bool altExists() =>
      widget.workoutsInDay
          ?.where((w) => w.id == widget.workout?.altParentId)
          .isNotEmpty ??
      false;

  ///                               ELEMENTS                                 ///

  List<Widget> getOtherAlternatives() {
    List<Widget> otherAlternatives = [];
    if (widget.workout != null && widget.workoutsInDay != null) {
      otherAlternatives = widget.workoutsInDay!
          .where((w) => w.altParentId == widget.workout?.id)
          .map((w) => Text(w.name))
          .toList();
    }

    return otherAlternatives;
  }

  List<DropdownMenuItem<String>> getPossibleAlternatives() {
    List<DropdownMenuItem<String>> dropdownList = [
      const DropdownMenuItem(
          value: '',
          child: Text('Alternative For', style: TextStyle(color: Colors.grey)))
    ];
    dropdownList.addAll(widget.workoutsInDay!
        .where((w) =>
            widget.workout == null ||
            (w.id != widget.workout?.id && w.altParentId != widget.workout?.id))
        .map((workout) =>
            DropdownMenuItem(child: Text(workout.name), value: workout.id)));
    return dropdownList;
  }

  Widget buildNameField() {
    if (_nameController.value.text.isEmpty) {
      _nameController = TextEditingController(text: widget.workout?.name);
    }

    return Expanded(
        key: _nameFieldKey,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 12, bottom: 18, left: 32, right: 32),
          child: TextFormField(
              controller: _nameController,
              validator: (String? value) => Validator.stringValidator(value,
                  defaultValue: widget.workout?.name),
              decoration: const InputDecoration(hintText: 'Name')),
        ));
  }

  Widget buildWeightField() {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 12, left: 32, right: 12),
      child: TextFormField(
          controller: _weightController,
          validator: (String? value) => Validator.doubleValidator(value,
              defaultValue: widget.workout?.weight),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              hintText: widget.workout?.weight.toString() ?? 'Weight',
              helperText: 'Weight')),
    ));
  }

  Widget buildSetsField() {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 12, left: 12, right: 12),
      child: TextFormField(
          controller: _setsController,
          validator: (String? value) =>
              Validator.intValidator(value, defaultValue: widget.workout?.sets),
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: InputDecoration(
              hintText: widget.workout?.sets.toString() ?? 'Sets',
              helperText: 'Sets')),
    ));
  }

  Widget buildRepsField() {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 12, left: 12, right: 32),
      child: TextFormField(
          controller: _repsController,
          validator: (String? value) =>
              Validator.intValidator(value, defaultValue: widget.workout?.reps),
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: InputDecoration(
              hintText: widget.workout?.reps.toString() ?? 'Reps',
              helperText: 'Reps')),
    ));
  }

  Widget buildNotesField() {
    if (_notesController.value.text.isEmpty) {
      _notesController = TextEditingController(text: widget.workout?.notes);
    }

    return SizedBox(
        key: _notesFieldKey,
        // height: 240,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 24, left: 32, right: 32),
          child: TextFormField(
            controller: _notesController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Notes'),
            onTap: () => Util().scrollToSelectedContext(_notesFieldKey),
          ),
        ));
  }

  Widget buildAlternatives() {
    if (widget.workoutsInDay != null && widget.workoutsInDay!.isNotEmpty) {
      if (widget.workout?.altParentId != null &&
          _alternativeId == null &&
          altExists()) {
        _alternativeId = widget.workout?.altParentId;
      }

      List<DropdownMenuItem<String>> possibleAlternatives =
          getPossibleAlternatives();
      List<Widget> otherAlternatives = getOtherAlternatives();

      return (possibleAlternatives.length > 1 || otherAlternatives.isNotEmpty)
          ? Expanded(
              key: _altDropdownKey,
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 12, bottom: 18, left: 32, right: 32),
                  child: Column(children: [
                    possibleAlternatives.length > 1
                        ? DropdownButton(
                            value: _alternativeId,
                            hint: const Text('Alternative For'),
                            isExpanded: true,
                            items: possibleAlternatives,
                            onChanged: (value) => setState(() {
                                  _alternativeId = value as String;
                                }))
                        : Container(),
                    otherAlternatives.isNotEmpty
                        ? ExpansionTile(
                            title: const Text('Alternatives',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                child: ListView(
                                    controller: _altScrollController,
                                    children: otherAlternatives),
                              )
                            ],
                          )
                        : Container(),
                  ])))
          : Container();
    }
    return Container();
  }

  Widget buildConfirmCancel() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      IconButton(
        iconSize: 32,
        icon: const Icon(Icons.cancel),
        onPressed: () {
          Navigator.of(context).pop();
          widget.rebuildCallback(
              workout: widget.workout, update: widget.workout != null);
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
            Row(
              children: [
                buildNameField(),
              ],
            ),
            Row(
              children: [
                buildWeightField(),
                buildSetsField(),
                buildRepsField(),
              ],
            ),
            Row(
              children: [
                Toggles.alternativeWorkouts ? buildAlternatives() : Container(),
              ],
            ),
            buildNotesField(),
            buildConfirmCancel(),
            SizedBox(height: MediaQuery.of(context).size.height * .34)
          ],
        ));
  }
}
