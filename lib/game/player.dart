import 'package:flutter/material.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';

class Player with InfinityLoop, OnCollisionCallBack {
  Player({required this.shooter, required this.shooterBody});
  late final RigidBody shooterBody;
  final InfinityObject shooter;

  double moveSpeed = 100;
  final double maxSpeed = 800;
  final double onGroundSpeed = 100;
  final double inAirSpeed = 200;

  final double dashForce = 300;
  double dashCooldown = 0.5;
  double dashDuration = 0.2;

  bool isOnGround = false;
  bool isDashing = false;

  final double jumpForce = 500;
  double jumpCooldown = 0.3;

  double hitIndicationCooldown = 0.3;

  final Color playerHitColor = const Color.fromARGB(255, 255, 0, 0);
  final Color playerColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  void update(double dt) {
    checkJump();
    checkSpeed();
    checkIfOnGround();
    checkHit();
    checkDash();
    moveShooter();
  }

  void checkHit() {
    if (hitIndicationCooldown > 0) {
      hitIndicationCooldown -= InfinityTime.deltaTime;
    }

    if (hitIndicationCooldown <= 0) {
      if (!shooter.isColliding) {
        shooter.color = playerColor;
      }
      hitIndicationCooldown = 0.3;
    }
  }

  void checkSpeed() {
    if (!isDashing) {
      // this is to allow more x velocity when dashing
      if (shooterBody.velocity.x > maxSpeed ||
          shooterBody.velocity.x < -maxSpeed) {
        shooterBody.velocity = Vector2(
          shooterBody.velocity.x * 0.9,
          shooterBody.velocity.y,
        );
      }

      if (shooterBody.velocity.x > 0 || shooterBody.velocity.x < 0) {
        shooterBody.velocity = Vector2(
          shooterBody.velocity.x * 0.9,
          shooterBody.velocity.y,
        );
      }
    }
  }

  void checkIfOnGround() {
    if (!shooter.isColliding) {
      isOnGround = false;
    }
    if (isOnGround) {
      moveSpeed = onGroundSpeed;
    } else {
      moveSpeed = inAirSpeed;
    }
  }

  void checkJump() {
    if (jumpCooldown > 0) {
      jumpCooldown -= InfinityTime.deltaTime;
    }
  }

  void checkDash() {
    final dt = InfinityTime.deltaTime;
    if (dashCooldown > 0) {
      dashCooldown -= dt;
    }
    if (isDashing) {
      dashDuration -= dt;
    }
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
    final Vector2 input = Vector2(moveSpeed, 0);
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
    shooterBody.addImpulse(direction * shooterBody.mass);
  }

  @override
  void onCollisionEvent(event) {
    if (event.other.object is BaseEnemy) {
      shooter.color = playerHitColor;
    }
    if (event.other.object.name == "Ground") {
      isOnGround = true;
    }
  }
}
