import 'package:flutter/material.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';

class Player with InfinityLoop, OnCollisionCallBack {
  Player({required this.shooter, required this.shooterBody});
  late final RigidBody shooterBody;
  final InfinityObject shooter;
  double moveSpeed = 100;
  bool isOnGround = false;
  final double onGroundSpeed = 100;
  final double inAirSpeed = 300;

  final double dashForce = 300;
  bool isDashing = false;
  double dashDuration = 0.3;
  double dashCooldown = 0.5;

  final double jumpForce = 500;
  double jumpCooldown = 0.3;

  double hitIndicationCooldown = 0.3;

  @override
  void update(double dt) {
    dashCooldown -= dt;
    jumpCooldown -= dt;
    if (isDashing) {
      dashDuration -= dt;
    }

    if (hitIndicationCooldown > 0) {
      hitIndicationCooldown -= dt;
    }

    if (hitIndicationCooldown <= 0) {
      if (!shooter.isColliding) {
        shooter.color = const Color.fromARGB(255, 25, 0, 255);
      }
      hitIndicationCooldown = 0.3;
    }

    if (isOnGround) {
      moveSpeed = onGroundSpeed;
    } else {
      moveSpeed = inAirSpeed;
    }

    if (!shooter.isColliding) {
      isOnGround = false;
    }

    moveShooter();
    if (dashDuration < 0) {
      shooterBody.velocity = Vector2(0, shooterBody.velocity.y);
      isDashing = false;
      dashDuration = 0.3;
    }
  }

  @override
  void start() {
    // TODO: implement start
  }

  void moveShooter() {
    final Vector2 input = Vector2(moveSpeed * InfinityTime.deltaTime, 0);
    Vector2 direction = Vector2.zero;
    if (InfinityInput.isAnyPressed([
      InfinityInput.keys.left,
      InfinityInput.keys.a,
    ])) {
      direction = -input;
    }
    if (InfinityInput.isAnyPressed([
      InfinityInput.keys.right,
      InfinityInput.keys.d,
    ])) {
      direction = input;
    }
    if (InfinityInput.isPressed(InfinityInput.keys.space) &&
        jumpCooldown <= 0) {
      shooterBody.addImpulse(Vector2(0, -jumpForce * shooterBody.mass));
      jumpCooldown = 0.3;
    }
    if (InfinityInput.isPressed(InfinityInput.keys.shift) &&
        dashCooldown <= 0) {
      isDashing = true;
      if (direction.x < 0) {
        shooterBody.addImpulse(Vector2(-dashForce * shooterBody.mass, 0));
      } else if (direction.x > 0) {
        shooterBody.addImpulse(Vector2(dashForce * shooterBody.mass, 0));
      }
      dashCooldown = 0.5;
    }
    shooter.position += direction;
  }

  @override
  void onCollisionEvent(event) {
    if (event.other.object is BaseEnemy) {
      shooter.color = const Color.fromARGB(255, 255, 0, 0);
    }
    if (event.other.object.name == "Ground") {
      isOnGround = true;
    }
  }
}
