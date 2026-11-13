import 'package:infinity_engine/game/game.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/singularity.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart'
    show InfinityEngine;

void main() {
  final engine = InfinityEngine();
  engine.debugMode = false; // Shows only Colliders for now
  engine.init();

  runApp(Singularity(rootLoop: HitThemGame()));
}

class HitThemGame extends SingularityLoop {
  @override
  void update(double dt) {}

  @override
  void start() {
    InfinityLayer.addLayer(InfinityLayer(name: "Background", zIndex: 0)); // Create a new Layer for background with zIndex = 0 to have behind everything
    final testObject = InfinityObject(
      state: InfinityObjectState(name: "Spawner")..visibility = false,
      loops: [Game()],
    );
    final backGround = InfinityUi(
      layer: InfinityLayer.getLayerByName(
        "Background",
      ), // putting the background under the "Background" layer
      child: flutter.Container(
        decoration: flutter.BoxDecoration(color: flutter.Colors.grey[900]),
        child: const flutter.Center(child: flutter.SizedBox.expand()),
      ),
    );
    InfinityEngine.addObject(backGround);
    InfinityEngine.addObject(testObject);
  }
}
