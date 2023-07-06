import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/model/workout_day.dart';
import 'package:swole_experience/service/db/workout_service.dart';
import 'package:swole_experience/util/error_handler.dart';
import 'package:swole_experience/util/validator.dart';
import 'package:swole_experience/util/weight_util.dart';

class ProgressionHelper extends StatefulWidget {
  const ProgressionHelper(
      {Key? key, required this.workout, required this.rebuildCallback})
      : super(key: key);

  final WorkoutDay workout;
  final Function rebuildCallback;

  @override
  State<ProgressionHelper> createState() => _ProgressionHelperState();
}

class _ProgressionHelperState extends State<ProgressionHelper> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Logger logger = Logger();

  final ScrollController _scrollController = ScrollController();
  TextEditingController _repsController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  int newReps = 0;
  double calculatedWeight = 0;
  double calculatedRoundedWeight = 0;

  double incrementField(TextEditingController field, double increment) {
    double? fieldValue = double.tryParse(field.value.text);
    if (fieldValue == null) {
      ErrorHandler().showAlert('Unable to increment field since it is empty.', context);
      return 0;
    } else {
      return ((fieldValue + increment) / 2.5).roundToDouble() * 2.5;
    }
  }

  void calculateWeight({bool explicitAction = false}) {
    int? repsInput = int.tryParse(_repsController.value.text);

    if (repsInput == null && explicitAction) {
      ErrorHandler().showAlert('Invalid value for reps field.,', context);
    } else if (repsInput != null) {
      double oneRepMax = WeightUtil.calculateExactOneRepMax(widget.workout);
      setState(() {
        newReps = repsInput;
        calculatedWeight = WeightUtil.calculateWeightForReps(repsInput, oneRepMax);
        if (explicitAction) {
          calculatedRoundedWeight =
              (calculatedWeight / 2.5).ceilToDouble() * 2.5;
        }
      });
    }
  }

  WorkoutDay updateWorkout() {
    WorkoutDay updatedWorkout = widget.workout.copy(
      reps: int.tryParse(_repsController.value.text),
      weight: double.tryParse(_weightController.value.text),
    );

    WorkoutService.svc
        .updateWorkout(updatedWorkout)
        .onError((error, trace) =>
            ErrorHandler().handleSaveError('update', error, trace, context))
        .then((res) {
      if (res != 0) {
        Navigator.of(context).pop();
        widget.rebuildCallback(
          workout: updatedWorkout,
          update: true,
        );
      }
    });
    return updatedWorkout;
  }

  ///                               Widgets                                  ///

  Widget buildRepsRow() {
    int reps = (newReps > 0) ? newReps : widget.workout.reps;
    _repsController = TextEditingController(text: reps.toString());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 42, child: Text(widget.workout.reps.toString())),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: Icon(Icons.arrow_circle_right_outlined)),
        SizedBox(
          width: MediaQuery.of(context).size.width * .40,
          child: TextFormField(
            controller: _repsController,
            validator: (String? value) => Validator.intValidator(value,
                defaultValue: widget.workout.reps),
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
                hintText: widget.workout.reps.toString(), helperText: 'Reps'),
            onChanged: (_) => calculateWeight(),
          ),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  newReps = (int.tryParse(_repsController.value.text) ?? 0) + 1;
                });
              }),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                setState(() {
                  newReps = (int.tryParse(_repsController.value.text) ?? 0) - 1;
                });
              }),
        ]),
      ],
    );
  }

  Widget buildWeightRow() {
    double weight = (calculatedRoundedWeight > 0)
        ? calculatedRoundedWeight
        : widget.workout.weight;
    _weightController = TextEditingController(text: weight.toStringAsFixed(1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 42, child: Text(widget.workout.weight.toString())),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: Icon(Icons.arrow_circle_right_outlined)),
        (calculatedWeight > 0)
            ? Padding(
                padding: const EdgeInsets.only(right: 24),
                child: SizedBox(
                    width: 48,
                    child: Text('(${calculatedWeight.toStringAsFixed(1)})')))
            : Container(),
        SizedBox(
            width: MediaQuery.of(context).size.width * .40,
            child: Row(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .40 - 50,
                child: TextFormField(
                  controller: _weightController,
                  validator: (String? value) => Validator.doubleValidator(value,
                      defaultValue: widget.workout.weight),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      hintText: widget.workout.weight.toString(),
                      helperText: 'Weight'),
                ),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            calculatedRoundedWeight =
                                incrementField(_weightController, 2.5);
                          });
                        }),
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            calculatedRoundedWeight =
                                incrementField(_weightController, -2.5);
                          });
                        }),
                  ]),
            ])),
      ],
    );
  }

  Widget buildCalculateButton() {
    double horizontalPadding = MediaQuery.of(context).size.width - 290;
    return Padding(
        padding: EdgeInsets.only(
            top: 24,
            bottom: 12,
            left: horizontalPadding,
            right: horizontalPadding),
        child: OutlinedButton(
            onPressed: () => calculateWeight(explicitAction: true),
            child: Row(children: const [
              Icon(Icons.calculate, color: CommonStyles.secondaryColour),
              Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text("Calculate Weight")),
            ])));
  }

  Widget buildConfirmCancel() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      IconButton(
        iconSize: 32,
        icon: const Icon(Icons.cancel),
        onPressed: () {
          Navigator.of(context).pop();
          widget.rebuildCallback(workout: widget.workout);
        },
      ),
      IconButton(
        iconSize: 32,
        icon: const Icon(Icons.check_circle, color: CommonStyles.primaryColour),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            updateWorkout();
          }
        },
      ),
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
        title: Text(widget.workout.name),
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            children: [
              buildRepsRow(),
              buildCalculateButton(),
              buildWeightRow(),
              buildConfirmCancel(),
            ],
          )),
    );
  }
}
