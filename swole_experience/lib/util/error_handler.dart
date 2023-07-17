import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:swole_experience/components/alert_snack_bar.dart';

class ErrorHandler {
  static final Logger logger = Logger();

  int handleSaveError(
      String operation, Object? error, StackTrace trace, BuildContext context) {
    Exception exception =
        (error is Exception) ? error : Exception('Something went wrong :(');
    (exception is FormatException)
        ? handleValidationSaveError(
            operation, exception.message, trace, context)
        : handleGenericSaveError(operation, exception, trace, context);
    return 0;
  }

  void handleValidationSaveError(
      operation, String message, StackTrace trace, BuildContext context) {
    logger.w('Error validating object: $message');
    showAlert(message, context);
  }

  void handleGenericSaveError(
      String operation, Exception ex, StackTrace trace, BuildContext context) {
    logger.e('Error ${operation}ing workout', ex, trace);
    showAlert('Unable to update or create the workout.', context);
  }

  void showAlert(String message, BuildContext context) {
    AlertSnackBar(
      message: message,
      state: SnackBarState.failure,
    ).alert(context);
  }
}
