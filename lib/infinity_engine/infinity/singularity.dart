import 'package:flutter/material.dart' as flutter;
import 'package:hit_them/infinity_engine/infinity/components/input_listener.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_tick.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';

class Singularity extends flutter.StatelessWidget {
  const Singularity({super.key, required this.rootLoop});

  final SingularityLoop rootLoop;

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.MaterialApp(
      home: flutter.Scaffold(
        body: InputListener(
          child: flutter.Stack(
            children: [
              InfinityTick(
                onLogicTick: (dt) {
                  InfinityEngine().loop(dt);
                },
                renderFps: InfinityEngine().fps,
                logicFps: InfinityEngine().fps,
              ),
              InfinityEngine().canvas,
            ],
          ),
        ),
      ),
    );
  }
}

void runApp(Singularity gameWidget) {
  final rootObject = InfinityObject(
    state: InfinityObjectState(name: "rootLoop", color: flutter.Colors.black),
    loops: [gameWidget.rootLoop],
  )..state.visible = false;
  InfinityEngine().addObject(rootObject);
  flutter.runApp(gameWidget);
  InfinityEngine().startEngine();
}

class SingularityLoop extends InfinityLoop {
  @override
  void update(dt) {}

  @override
  void start() {}
}
