import 'package:flutter/foundation.dart';
import 'package:hit_them/infinity_engine/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';
import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity_physics/rigidbody.dart';
import 'package:hit_them/infinity_engine/infinity_input/infinity_input.dart';

class PhysicsGame extends InfinityLoop {
  late final InfinityObject player;
  late final InfinityObject ground;
  late final RigidBody playerBody;

  final Vector2 gravity = const Vector2(0, 980.0); // Pixels / sec^2

  @override
  void start() {
    player = InfinityObject(
      state: InfinityObjectState(
        name: "PhysicsPlayer",
        color: Colors.blue,
        position: const Vector2(100, 100),
        size: const Size(40, 40),
      ),
    );
    playerBody = RigidBody(object: player, mass: 1.0, drag: 00.8);
    player.addComponent(playerBody);
    InfinityEngine().addObject(player);

    ground = InfinityObject(
      state: InfinityObjectState(
        name: "PhysicsGround",
        color: Colors.green,
        position: const Vector2(0, 500),
        size: const Size(800, 100),
      ),
    );
    InfinityEngine().addObject(ground);
  }

  @override
  void update(double dt) {
    // 1. Apply constant forces (Gravity)
    playerBody.addForce(gravity * playerBody.mass);

    // 2. Apply player input as force or impulse
    const double moveForce = 1500.0;
    if (InfinityInput.isPressed(InfinityInput.keys.a)) {
      playerBody.addForce(const Vector2(-moveForce, 0));
    }
    if (InfinityInput.isPressed(InfinityInput.keys.d)) {
      playerBody.addForce(const Vector2(moveForce, 0));
    }
  }
}
