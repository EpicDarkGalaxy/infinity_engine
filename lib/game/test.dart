import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_input/infinity_input.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';

class Game extends InfinityLoop {
  late final InfinityObject box;
  final double speed = 300.0; // Increased to standard pixel velocity

  @override
  void update(double dt) {
    Vector2 velocity = Vector2.zero;

    if (InfinityInput.isPressed(InfinityInput.keys.w)) {
      velocity = velocity + Vector2.up;
    }
    if (InfinityInput.isPressed(InfinityInput.keys.s)) {
      velocity = velocity + Vector2.down;
    }
    ;
    if (InfinityInput.isPressed(InfinityInput.keys.a)) {
      velocity = velocity + Vector2.left;
    }
    if (InfinityInput.isPressed(InfinityInput.keys.d)) {
      velocity = velocity + Vector2.right;
    }

    // Normalize diagonal vector so movement speed stays consistent
    if (velocity.magnitudeSquared > 0) {
      velocity = velocity.normalized;

      final currentPos = box.state.position;
      final newPos = currentPos + (velocity * speed * dt);

      box.position = newPos;
    }
  }

  @override
  void start() {
    box = InfinityObject(
      state: InfinityObjectState(
        name: "From Test.dart",
        color: Colors.black,
        position: Vector2(100, 100),
        size: const Size(50, 50),
      ),
    );
    InfinityEngine().addObject(box);
  }
}
