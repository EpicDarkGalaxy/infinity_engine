import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/components.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';

class Game extends InfinityLoop {
  late final InfinityObject shooter;
  late final RigidBody shooterBody;

  final List<InfinityObject> enemies = [];
  final int maxEnemies = 5;

  final double moveSpeed = 300;
  double enemyMoveSpeed = 100;
  final double jumpForce = 500;
  final double jumpInterval = 0.3;
  double jumpIntervalCounter = 0;

  double hitIndicationCooldown = 0.3;

  // Reactive score notifier for high-performance UI updates
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  late InfinityUi scoreText;

  @override
  void update(double dt) {
    jumpIntervalCounter += dt;
    moveShooter();
    moveEnemy();

    if (hitIndicationCooldown > 0) {
      hitIndicationCooldown -= dt;
    }

    if (hitIndicationCooldown <= 0) {
      if (!shooter.isColliding) {
        shooter.color = Colors.cyanAccent;
      }
      hitIndicationCooldown = 0.3;
    }

    if (enemies.length < maxEnemies) {
      spawnEnemy();
    }
  }

  void checkCollision(InfinityObject other) {
    if (other.state.name == "Enemy") {
      shooter.color = Colors.greenAccent;
      enemies.remove(other);
      InfinityEngine.removeObject(other);

      scoreNotifier.value++;
      enemyMoveSpeed += 3;
    } else {
      shooter.color = Colors.cyanAccent;
      hitIndicationCooldown = 0.3;
    }
  }

  void moveShooter() {
    final Vector2 input = Vector2(moveSpeed * InfinityTime.deltaTime, 0);
    if (InfinityInput.isPressed(InfinityInput.keys.left)) {
      shooter.position += -input;
    }
    if (InfinityInput.isPressed(InfinityInput.keys.right)) {
      shooter.position += input;
    }
    if (InfinityInput.isPressed(InfinityInput.keys.space)) {
      if (jumpIntervalCounter > jumpInterval) {
        shooterBody.addImpulse(Vector2(0, -jumpForce * shooterBody.mass));
        jumpIntervalCounter = 0;
      }
    }
  }

  void moveEnemy() {
    final Vector2 input = Vector2(0, enemyMoveSpeed * InfinityTime.deltaTime);

    for (var enemy in enemies) {
      enemy.position += input;
    }

    enemies.removeWhere((element) {
      if (element.position.y > 1000) {
        InfinityEngine.removeObject(element);
        return true;
      }
      return false;
    });
  }

  void spawnEnemy() {
    final enemy = InfinityObject(
      state: InfinityObjectState(
        name: "Enemy",
        position: Vector2(Random().nextDouble() * 950, -200),
        size: Vector2(45, 45),
        color: Colors.deepOrangeAccent,
      ),
    );
    enemy.addComponent(RigidBody(object: enemy, useGravity: false, mass: 10));
    enemy.addComponent(AABBCollider(object: enemy));
    InfinityEngine.addObject(enemy);
    enemies.add(enemy);
  }

  @override
  void start() {
    setUpShooter();

    // Styled arcade HUD using ValueListenableBuilder
    scoreText = InfinityUi(
      padding: const EdgeInsets.all(16.0),
      child: ValueListenableBuilder<int>(
        valueListenable: scoreNotifier,
        builder: (context, score, child) {
          return Text(
            "SCORE: $score",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.yellowAccent,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          );
        },
      ),
    );
    InfinityEngine.addObject(scoreText);
  }

  void setUpShooter() {
    shooter = InfinityObject(
      state: InfinityObjectState(
        name: "Shooter",
        position: Vector2(300, 500),
        size: Vector2(50, 50),
        color: Colors.cyanAccent,
      ),
    );
    shooterBody = RigidBody(object: shooter, useGravity: true, mass: 10);
    shooter.addComponent(shooterBody);
    shooter.addComponent(
      AABBCollider(
        object: shooter,
        onCollision: (other) {
          checkCollision(other);
        },
      ),
    );
    InfinityEngine.addObject(shooter);
  }
}
