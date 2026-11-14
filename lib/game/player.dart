import 'package:flutter/material.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';

class PlayerStats {
  static int health = 100;
  static int maxHealth = 100;
  static int damage = 50;
}

class PlayerState {
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
}

class Player extends InfinityObject with InfinityLoop, OnCollisionCallBack {
  Player({super.key, required InfinityObjectState state}) : super(state: state);
  final PlayerStats stats = PlayerStats();
  final PlayerState _playerState = PlayerState();
  late final RigidBody shooterBody;

  final Color playerHitColor = const Color.fromARGB(255, 255, 0, 0);
  final Color playerColor = const Color.fromARGB(255, 255, 255, 255);

  PlayerState get playerState => _playerState;

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
    if (_playerState.hitIndicationCooldown > 0) {
      _playerState.hitIndicationCooldown -= InfinityTime.deltaTime;
    }

    if (_playerState.hitIndicationCooldown <= 0) {
      if (!isColliding) {
        color = playerColor;
      }
      _playerState.hitIndicationCooldown = 0.3;
    }
  }

  void checkSpeed() {
    // this is to allow more x velocity when dashing
    if (!_playerState.isDashing) {
      // Prevernts the player from reaching another dimension
      if (shooterBody.velocity.x > _playerState.maxSpeed ||
          shooterBody.velocity.x < -_playerState.maxSpeed) {
        shooterBody.velocity = Vector2(
          shooterBody.velocity.x * 0.9,
          shooterBody.velocity.y,
        );
      }

      // Slow down the player when not pressing anything
      if (shooterBody.velocity.x > 0 || shooterBody.velocity.x < 0) {
        shooterBody.velocity = Vector2(
          shooterBody.velocity.x * 0.8,
          shooterBody.velocity.y,
        );
      }
    }
  }

  void checkIfOnGround() {
    if (!isColliding) {
      _playerState.isOnGround = false;
    }
    if (_playerState.isOnGround) {
      _playerState.moveSpeed = _playerState.onGroundSpeed;
    } else {
      _playerState.moveSpeed = _playerState.inAirSpeed;
    }
  }

  void checkJump() {
    if (_playerState.jumpCooldown > 0) {
      _playerState.jumpCooldown -= InfinityTime.deltaTime;
    }
  }

  void checkDash() {
    final dt = InfinityTime.deltaTime;
    if (_playerState.dashCooldown > 0) {
      _playerState.dashCooldown -= dt;
    }
    if (_playerState.isDashing) {
      _playerState.dashDuration -= dt;
    }
    if (_playerState.dashDuration < 0) {
      shooterBody.velocity = Vector2(0, shooterBody.velocity.y);
      _playerState.isDashing = false;
      _playerState.dashDuration = 0.3;
    }
  }

  @override
  void start() {
    final body = getComponent<RigidBody>();
    if (body != null) {
      shooterBody = body;
    }
  }

  void moveShooter() {
    final Vector2 input = Vector2(_playerState.moveSpeed, 0);
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
        _playerState.jumpCooldown <= 0) {
      shooterBody.addImpulse(
        Vector2(0, -_playerState.jumpForce * shooterBody.mass),
      );
      _playerState.jumpCooldown = 0.3;
    }
    if (InfinityInput.isPressed(InfinityInput.keys.shift) &&
        _playerState.dashCooldown <= 0) {
      _playerState.isDashing = true;
      if (direction.x < 0) {
        shooterBody.addImpulse(
          Vector2(-_playerState.dashForce * shooterBody.mass, 0),
        );
      } else if (direction.x > 0) {
        shooterBody.addImpulse(
          Vector2(_playerState.dashForce * shooterBody.mass, 0),
        );
      }
      _playerState.dashCooldown = 0.5;
    }
    shooterBody.addImpulse(direction * shooterBody.mass);
  }

  @override
  void onCollisionEvent(event) {
    if (event.other.object is BaseEnemy) {
      color = playerHitColor;
    }
    if (event.other.object.name == "Ground") {
      _playerState.isOnGround = true;
    }
  }
}
