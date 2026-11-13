import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/game/enemies/ground_eater_enemy.dart';
import 'package:infinity_engine/game/enemies/keel_enemy.dart';
import 'package:infinity_engine/game/enemies/tough_enemy.dart';
import 'package:infinity_engine/game/enemies/weak_enemy.dart';
import 'package:infinity_engine/game/player.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class Game with InfinityLoop, OnCollisionCallBack {
  final List<BaseEnemy> enemies = [];
  final List<BaseEnemy Function()> enemyPool = [
    () => WeakEnemy(),
    () => ToughEnemy(),
    () => GroundEaterEnemy(),
    () => KeelEnemy(),
  ];
  final int maxEnemies = 5;
  int score = 0;

  // Reactive score notifier for high-performance UI updates
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  late InfinityUi scoreText;

  @override
  void update(double dt) {
    moveEnemy();

    if (enemies.length < maxEnemies) {
      spawnEnemy();
    }
  }

  void moveEnemy() {
    for (var enemy in enemies) {
      enemy.move(InfinityTime.deltaTime);
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
    final enemy = enemyPool[Random().nextInt(enemyPool.length)]();
    enemy.position = Vector2(Random().nextDouble() * 950, -200);
    final layer = InfinityLayer.getLayerByName("Enemy");
    if (layer != null) {
      enemy.layer = layer;
    }
    enemy.addComponent(RigidBody(object: enemy, useGravity: false, mass: 10));
    enemy.addComponent(
      AABBCollider(
        object: enemy,
        ignore: [InfinityLayer.getLayerByName("Ground")!],
        onCollision: (other) {
          if (other.object.name == "Shooter") {
            score++;
            scoreNotifier.value = score;
          }
        },
      ),
    );
    InfinityEngine.addObject(enemy);
    enemies.add(enemy);
  }

  @override
  void start() {
    // Create Layers
    final enemyLayer = InfinityLayer(
      name: "Enemy",
      zIndex: 1,
      isCollidable: true,
    );
    final shooterLayer = InfinityLayer(
      name: "Shooter",
      zIndex: 2,
      isCollidable: true,
    );
    final groundLayer = InfinityLayer(
      name: "Ground",
      zIndex: 3,
      isCollidable: true,
    );
    // Add Layers to Engine
    InfinityLayer.addLayer(enemyLayer);
    InfinityLayer.addLayer(shooterLayer);
    InfinityLayer.addLayer(groundLayer);
    setUpShooter();
    setUpGround();
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
    final shooter = InfinityObject(
      state: InfinityObjectState(
        name: "Shooter",
        position: Vector2(300, 500),
        size: Vector2(50, 50),
        color: const Color.fromARGB(255, 25, 0, 255),
        layer: InfinityLayer.getLayerByName("Shooter")!,
      ),
    );
    final shooterBody = RigidBody(
      object: shooter,
      useGravity: true,
      mass: 20,
      gravityScale: 1.2,
    );
    shooter.addLoop(Player(shooter: shooter, shooterBody: shooterBody));
    shooter.addComponent(shooterBody);
    shooter.addComponent(AABBCollider(object: shooter));
    InfinityEngine.addObject(shooter);
  }

  void setUpGround() {
    final ground = InfinityObject(
      state: InfinityObjectState(
        name: "Ground",
        position: Vector2(0, 700),
        size: Vector2(1300, 50),
        color: Colors.green,
      ),
    );
    ground.addComponent(RigidBody(object: ground, isStatic: true));
    ground.addComponent(
      AABBCollider(
        object: ground,
        ignore: [InfinityLayer.getLayerByName("Enemy")!],
      ),
    );
    InfinityEngine.addObject(ground);
  }
}
