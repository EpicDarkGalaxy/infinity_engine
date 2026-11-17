import 'package:flutter/material.dart' show Colors;
import 'package:infinity_engine/infinity_engine.dart';

void main() {
  InfinityEngine().init();
  runApp(Singularity(rootLoop: ExampleLoop()));
}

class ExampleLoop extends SingularityLoop {
  late final InfinityObject player;

  @override
  void start() {
    player = InfinityObject(
      state: InfinityObjectState(
        name: 'player',
        position: const Vector2(32, 96),
        size: const Vector2(48, 48),
        color: Colors.cyan,
      ),
    );
    InfinityEngine.addObject(player);
  }

  @override
  void update(double dt) {
    player.position = player.position + Vector2(60 * dt, 0);
  }
}
