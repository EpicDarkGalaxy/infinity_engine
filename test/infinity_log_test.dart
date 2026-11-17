import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/src/components/infinity_log.dart';
import 'package:infinity_engine/src/infinity_engine.dart';

void main() {
  final engine = InfinityEngine();
  late DebugPrintCallback originalDebugPrint;
  final messages = <String>[];

  setUp(() {
    originalDebugPrint = debugPrint;
    messages.clear();
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };
    engine.suppressInfoLogs = false;
    engine.suppressWarningLogs = false;
    engine.suppressErrorLogs = false;
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
    engine.suppressInfoLogs = false;
    engine.suppressWarningLogs = false;
    engine.suppressErrorLogs = false;
  });

  test('engine suppression flags independently filter log levels', () {
    engine.suppressWarningLogs = true;
    engine.suppressErrorLogs = true;

    InfinityLog.i('info');
    InfinityLog.w('warning');
    InfinityLog.e('error');

    expect(messages, ['info']);

    engine.suppressInfoLogs = true;
    InfinityLog.i('suppressed info');

    expect(messages, ['info']);
  });
}
