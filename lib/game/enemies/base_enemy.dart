import 'dart:ui';

import 'package:infinity_engine/game/player.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class EnemyState {
  EnemyState({
    this.health = 100,
    this.attack = 10,
    this.defense = 5,
    this.speed = 100,
    this.level = 1,
    this.experience = 100,
  });
  int health;
  int attack;
  int defense;
  int speed;
  int level;
  int experience;
}

class BaseEnemy extends InfinityObject with OnCollisionCallBack {
  BaseEnemy({
    super.key,
    String name = "Enemy",
    EnemyState? enemyState,
    super.state,
  }) {
    enemyState = enemyState ?? EnemyState();
    this.enemyState = enemyState;
    state.name = name;
  }
  late final EnemyState enemyState;
  @override
  set color(Color newColor) {
    // TODO: implement color
    super.color = newColor;
  }

  late final void Function() onDeath;

  @override
  void onCollisionEvent(CollisionEvent event) {
    if (event.other.object is Player) {
      enemyState.health -= PlayerStats.damage;
      if (enemyState.health <= 0) {
        ParticleSystem.burst(
          position: position + size / 2,
          color: color,
          layer: layer,
        );
        onDeath();
        InfinityEngine.removeObject(this);
      }
    }
  }

  void move(double dt) {
    position = Vector2(position.x, position.y + enemyState.speed * dt);
  }
}
