import 'package:flutter/material.dart';

enum SnackBarState {
  success,
  failure,
  warning,
}

class AlertSnackBar {
  const AlertSnackBar({required this.message, required this.state}) : super();

  final String message;
  final SnackBarState state;

  Icon getIcon() {
    switch (state) {
      case SnackBarState.success:
        {
          return const Icon(Icons.thumb_up, color: Color(0xff4af699));
        }
      case SnackBarState.failure:
        {
          return const Icon(Icons.error_outline, color: Color(0xffff0000));
        }
        break;
      case SnackBarState.warning:
        {
          return const Icon(Icons.warning_amber, color: Color(0xffeed202));
        }
      default:
        {
          // Fall back on info
          return const Icon(Icons.info);
        }
    }
  }

  void alert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                getIcon(),
                const SizedBox(
                  width: 20,
                ),
                Text(message),
              ],
            ))));
  }
}
