import 'package:flutter/foundation.dart';

class InfinityLog {
  static bool _suppressInfoLogs = false;
  static bool _suppressDebugLogs = false;
  static bool _suppressWarningLogs = false;
  static bool _suppressErrorLogs = false;

  static bool get suppressInfoLogs => _suppressInfoLogs;
  static set suppressInfoLogs(bool value) => _suppressInfoLogs = value;

  static bool get suppressDebugLogs => _suppressDebugLogs;
  static set suppressDebugLogs(bool value) => _suppressDebugLogs = value;

  static bool get suppressWarningLogs => _suppressWarningLogs;
  static set suppressWarningLogs(bool value) => _suppressWarningLogs = value;

  static bool get suppressErrorLogs => _suppressErrorLogs;
  static set suppressErrorLogs(bool value) => _suppressErrorLogs = value;

  static void i(String message) {
    if (_suppressInfoLogs) return;
    _print(message, "Info");
  }

  static void d(String message) {
    if (_suppressDebugLogs) return;
    _print(message, "Debug");
  }

  static void w(String message) {
    if (_suppressWarningLogs) return;
    _print(message, "Warning");
  }

  static void e(String message) {
    if (_suppressErrorLogs) return;
    _print(message, "Error");
  }

  static void _print(String message, String logLevel) {
    if (!kDebugMode) return;
    debugPrint("$logLevel: $message [Engine]");
  }
}
