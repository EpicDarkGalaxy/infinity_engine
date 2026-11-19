import 'package:flutter/material.dart' show BoxShape, Colors;
import 'package:infinity_engine/infinity_engine.dart';

void main() {
  InfinityEngine().init();
  runApp(Singularity(defaultScene: ExampleScene()));
}

class ExampleScene extends SingularityLoop {
  late final InfinityObject player;

  @override
  void onLoad() {
    player = InfinityObject(
      state: InfinityObjectState(
        name: 'player',
        position: const Vector2(32, 96),
        size: const Vector2(48, 48),
        color: Colors.cyan,
        shape: BoxShape.circle,
      ),
    );
    InfinityEngine.addObject(player);
  }

  @override
  void update(double dt) {
    player.position = player.position + Vector2(60 * dt, 0);
  }
}
