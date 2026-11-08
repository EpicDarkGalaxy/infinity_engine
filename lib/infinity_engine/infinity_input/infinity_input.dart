import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hit_them/infinity_engine/infinity_input/infinity_key_map.dart';

class InfinityInput {
  static final Set<LogicalKeyboardKey> _pressedKeys = {};

  static const InfinityKeyMap keys = InfinityKeyMap();

  static int get keyCountPressed => _pressedKeys.length;

  static bool isPressed(LogicalKeyboardKey key) {
    return _pressedKeys.contains(key);
  }

  static KeyEventResult handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
      return KeyEventResult.handled;
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
