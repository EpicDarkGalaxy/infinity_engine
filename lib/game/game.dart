import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';
import 'package:hit_them/infinity_engine/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_physics/colliders/aabb.dart';
import 'package:hit_them/infinity_engine/infinity_physics/rigidbody.dart';
import 'package:hit_them/infinity_engine/infinity_time.dart';

class Game extends InfinityLoop {
  late final InfinityObject box;
  late final RigidBody boxBody;
  late final AABBCollider boxCollider;

  late final InfinityObject ground;
  late final RigidBody groundBody;
  late final AABBCollider groundCollider;

  final double fallingSpeed = 100.0;
  final double gravity = 9.8;
  final double jumpForce = 100.0;

  bool isOnGround = false;

  @override
  void update(double deltaTime) {}

  @override
  void start() {
    box = InfinityObject(
      state: InfinityObjectState(id: "2", name: "Box", color: Colors.red),
    );
    boxBody = RigidBody(object: box, mass: 0.1, drag: 0.01, useGravity: true);
    boxCollider = AABBCollider(
      object: box,
      onCollision: (InfinityObject other) {
        if (other.state.name == "Ground") {
          print("Collided with ground");
        }
      },
      bounciness: Vector2(0.5, 0.5),
    );
    box.addComponent(boxBody);
    box.addComponent(boxCollider);

    ground = InfinityObject(
      state: InfinityObjectState(
        name: "Ground",
        color: Colors.green,
        position: const Vector2(0, 500),
        size: const Vector2(1000, 100),
      ),
    );
    groundBody = RigidBody(object: ground, mass: 0, drag: 0);
    groundCollider = AABBCollider(object: ground);
    ground.addComponent(groundBody);
    ground.addComponent(groundCollider);

    InfinityEngine.addObject(box);
    InfinityEngine.addObject(ground);
  }
}
