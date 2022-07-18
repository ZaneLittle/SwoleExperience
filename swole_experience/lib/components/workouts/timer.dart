import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swole_experience/constants/common_styles.dart';

class WorkoutTimer extends StatefulWidget {
  const WorkoutTimer({Key? key, this.context, this.dataSnapshot})
      : super(key: key);

  final BuildContext? context;
  final AsyncSnapshot<List<List<dynamic>>>? dataSnapshot;

  @override
  State<WorkoutTimer> createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  final GlobalKey<_WorkoutTimerState> _workoutListKey =
      GlobalKey<_WorkoutTimerState>();

  final Color btnColour = CommonStyles.primaryColour;

  Duration duration = const Duration();
  Timer? timer;
  bool running = false;
  String buttonText = 'Start';

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    setState(() {
      duration = const Duration();
    });
  }

  void addTime() {
    setState(() {
      duration = Duration(milliseconds: duration.inMilliseconds + 10);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (_) => addTime());
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  void toggleTimer() {
    if (running) {
      setState(() => timer?.cancel());
    } else {
      startTimer();
    }
    running = !running;
  }

  /// Builds the reset button.
  /// If timer is stopped and is at 00:00, build a timer icon that does nothing
  /// If timer is running, build a timer icon that does nothing
  /// If timer is stopped and has time on it, build a reset button
  Widget buildResetButton() {
    if (running || duration.inMilliseconds == 0) {
      return Icon(Icons.timer, color: btnColour);
    } else {
      return IconButton(
          onPressed: () {
            reset();
          },
          icon: Icon(Icons.refresh, color: btnColour));
    }
  }

  Icon getStartStopIcon() {
    if (running) {
      return Icon(Icons.pause, color: btnColour);
    } else {
      return Icon(Icons.play_arrow, color: btnColour);
    }
  }

  Widget buildTimer(String text) {
    return Row(
      children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * .3,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              buildResetButton(),
            ])),
        SizedBox(
            width: MediaQuery.of(context).size.width * .4,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                    '${twoDigits(duration.inMinutes.remainder(60))} : '
                    '${twoDigits(duration.inSeconds.remainder(60))} : '
                    '${twoDigits((duration.inMilliseconds.remainder(1000) / 10).round())}',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
            ])),
        SizedBox(
            width: MediaQuery.of(context).size.width * .3,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                icon: getStartStopIcon(),
                onPressed: () {
                  toggleTimer();
                },
              ),
            ]))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _workoutListKey,
      height: 48,
      child: Align(
          alignment: Alignment.bottomCenter, child: buildTimer(buttonText)),
    );
  }
}
