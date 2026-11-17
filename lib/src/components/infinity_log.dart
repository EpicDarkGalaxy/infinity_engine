import 'package:flutter/foundation.dart';

class InfinityLog {
  static void i(String message) {
    _print(message);
  }

  static void w(String message) {
    _print(message);
  }

  static void e(String message) {
    _print(message);
  }

  static void _print(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
