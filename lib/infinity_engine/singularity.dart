import 'package:flutter/material.dart' as flutter;
import 'package:hit_them/infinity_engine/components/collider_debug_painter.dart';
import 'package:hit_them/infinity_engine/components/input_listener.dart';
import 'package:hit_them/infinity_engine/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_tick.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';
import 'package:hit_them/infinity_engine/infinity_time.dart';

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
              InfinityEngine().debugMode
                  ? flutter.Positioned.fill(
                      child: flutter.IgnorePointer(
                        child: flutter.CustomPaint(
                          painter: ColliderDebugPainter(
                            engine: InfinityEngine(),
                          ),
                        ),
                      ),
                    )
                  : flutter.SizedBox.shrink(),
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
    loops: [gameWidget.rootLoop, InfinityTime()],
  )..visible = false;
  InfinityEngine.addObject(rootObject);
  flutter.runApp(gameWidget);
  InfinityEngine().startEngine();
}

/// First Loop of the game
class SingularityLoop extends InfinityLoop {
  @override
  void update(dt) {}

  @override
  void start() {}
}
