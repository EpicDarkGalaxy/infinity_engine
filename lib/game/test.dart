import 'package:flutter/rendering.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';

class Game extends InfinityLoop {
  @override
  void update(double deltaTime) {
    debugPrint("from game");
  }

  @override
  void start() {
    debugPrint("game started");
  }
}
