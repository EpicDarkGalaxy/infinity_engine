import 'package:flutter/rendering.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';

class Game extends InfinityEngine {
  late final InfinityObject box;
  Game() : super.init();

  @override
  void update(double dt) {
    debugPrint('dt: $dt');
    box.position = Offset(
      box.state.position.dx + (50 * dt),
      box.state.position.dy + (50 * dt),
    );
  }

  @override
  void start() {
    box = InfinityObject(state: InfinityObjectState());
    InfinityEngine().addObject(box);
  }
}
