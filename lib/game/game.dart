import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/game/enemies/tough_enemy.dart';
import 'package:infinity_engine/game/enemies/weak_enemy.dart';
import 'package:infinity_engine/game/player.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class Game with InfinityLoop {
  final List<BaseEnemy> enemies = [];
  final List<BaseEnemy Function()> enemyPool = [
    () => WeakEnemy(),
    () => ToughEnemy(),
  ];
  final int maxEnemies = 5;

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
    final shooter = InfinityObject(
      state: InfinityObjectState(
        name: "Shooter",
        position: Vector2(300, 500),
        size: Vector2(50, 50),
        color: const Color.fromARGB(255, 25, 0, 255),
      ),
    );
    final shooterBody = RigidBody(object: shooter, useGravity: true, mass: 10);
    shooter.loops.add(Player(shooter: shooter, shooterBody: shooterBody));
    shooter.addComponent(shooterBody);
    shooter.addComponent(AABBCollider(object: shooter));
    InfinityEngine.addObject(shooter);
  }
}
