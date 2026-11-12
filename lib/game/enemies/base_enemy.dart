import 'dart:ui';

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

  @override
  void onCollisionEvent(CollisionEvent event) {
    if (event.other.object.name == "Shooter") {
      enemyState.health -= 100;
      if (enemyState.health <= 0) {
        InfinityEngine.removeObject(this);
      }
    }
  }

  void move(double dt) {
    position = Vector2(position.x, position.y + enemyState.speed * dt);
  }
}
