import 'package:flutter/material.dart';

import 'package:swole_experience/constants/common_styles.dart';
import 'package:swole_experience/service/timer_service.dart';

class WorkoutTimer extends StatefulWidget {
  const WorkoutTimer({Key? key}) : super(key: key);

  @override
  State<WorkoutTimer> createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {

  TimerService svc = TimerService();
  String buttonText = 'Start';
  final Color btnColour = CommonStyles.primaryColour;

  String twoDigits(int n) => n.toString().padLeft(2, '0');


  /// If timer is stopped and is at 00:00, build a timer icon that does nothing
  /// If timer is running, build a timer icon that does nothing
  /// If timer is stopped and has time on it, build a reset button
  Widget buildResetButton() {
    if (svc.isRunning || svc.currentDuration.inMilliseconds == 0) {
      return Icon(Icons.timer, color: btnColour);
    } else {
      return IconButton(
          onPressed: svc.reset,
          icon: Icon(Icons.refresh, color: btnColour));
    }
  }

  Icon getStartStopIcon() {
    if (svc.isRunning) {
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
                  '${twoDigits(svc.currentDuration.inMinutes.remainder(60))} : '
                      '${twoDigits(svc.currentDuration.inSeconds.remainder(60))} : '
                      '${twoDigits((svc.currentDuration.inMilliseconds.remainder(1000) / 10).round())}',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
            ])),
        SizedBox(
            width: MediaQuery.of(context).size.width * .3,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                icon: getStartStopIcon(),
                onPressed: !svc.isRunning ? svc.start : svc.stop,
              ),
            ]))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    svc = TimerService.of(context);
    return Center(
        child: AnimatedBuilder(
          animation: svc, // listen to ChangeNotifier
          builder: (context, child) {
            return SizedBox(
              height: 48,
              child: Align(
                  alignment: Alignment.bottomCenter, child: buildTimer(buttonText)),
            );
          },
        ),
      );
  }
}
