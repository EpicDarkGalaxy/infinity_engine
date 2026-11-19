import 'package:flutter/foundation.dart';

class InfinityLog {
  static bool suppressInfoLogs = false;
  static bool suppressDebugLogs = false;
  static bool suppressWarningLogs = false;
  static bool suppressErrorLogs = false;

  static void i(String message) {
    if (suppressInfoLogs) return;
    _print(message, "Info");
  }

  static void d(String message) {
    if (suppressDebugLogs) return;
    _print(message, "Debug");
  }

  static void w(String message) {
    if (suppressWarningLogs) return;
    _print(message, "Warning");
  }

  static void e(String message) {
    if (suppressErrorLogs) return;
    _print(message, "Error");
  }

  static void _print(String message, String logLevel) {
    if (!kDebugMode) return;
    debugPrint("$logLevel: $message [Engine]");
  }
}
