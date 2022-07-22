import 'package:flutter/cupertino.dart';

/// General utility functions
class Util {
  void scrollToSelectedContext(GlobalKey key) {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }
}