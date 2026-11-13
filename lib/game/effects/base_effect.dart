import 'package:infinity_engine/game/effects/effect_container.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:flutter/material.dart';

class BaseEffect {
  BaseEffect({required this.parent, required this.target});

  final InfinityObject parent;
  final InfinityObject target;

  bool isActive = false;
  double duration = 0;
  double timer = 0;

  InfinityUi buildUI(ValueNotifier<int> listener, padding, name) {
    return InfinityUi(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      name: name,
      child: ValueListenableBuilder<int>(
        valueListenable: listener,
        builder: (context, value, child) {
          return Text(
            "$name: $value",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          );
        },
      ),
    );
  }

  void apply() {}
}
