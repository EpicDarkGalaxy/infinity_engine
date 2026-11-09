import 'package:hit_them/game/game.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:hit_them/infinity_engine/components.dart';
import 'package:hit_them/infinity_engine/singularity.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart'
    show InfinityEngine;

void main() {
  final engine = InfinityEngine();
  engine.debugMode = false;
  engine.init();

  runApp(Singularity(rootLoop: HitThemGame()));
}

class HitThemGame extends SingularityLoop {
  @override
  void update(double dt) {}

  @override
  void start() {
    InfinityLayer.addLayer(InfinityLayer(name: "Background", zIndex: 0));
    final testObject = InfinityObject(
      state: InfinityObjectState(name: "Spawner")..isVisible = false,
      loops: [Game()],
    );
    final backGround = InfinityUi(
      layer: InfinityLayer.getLayerByName("Background"),
      child: flutter.Container(
        decoration: flutter.BoxDecoration(color: flutter.Colors.black),
        child: const flutter.Center(child: flutter.SizedBox.expand()),
      ),
    );
    InfinityEngine.addObject(backGround);
    InfinityEngine.addObject(testObject);
  }
}
