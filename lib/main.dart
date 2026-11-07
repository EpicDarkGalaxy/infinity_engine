import 'package:flutter/material.dart';
import 'package:hit_them/game/test.dart';
import 'package:hit_them/infinity_engine/infinity/components/infinity_tick.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';

import 'infinity_engine/infinity_engine.dart';

void main() {
  final engine = InfinityEngine();
  engine.init();
  engine.addObject(
    InfinityObject(
      id: "s",
      name: "O",
      position: Offset(100, 100),
      color: Colors.red,
      size: Size(100, 100),
      shape: BoxShape.rectangle,
      loops: [Game()],
    ),
  );
  engine.runEngine(HitThemGame());
}

class HitThemGame extends StatelessWidget {
  const HitThemGame({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Stack(
          children: [
            InfinityTick(
              tick: (dt) {
                InfinityEngine().loop(dt);
              },
              targetFps: InfinityEngine().fps,
            ),
            InfinityEngine().canvas,
          ],
        ),
      ),
    );
  }
}
