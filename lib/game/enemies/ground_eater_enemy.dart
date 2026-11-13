import 'package:flutter/material.dart';
import 'package:infinity_engine/game/effects/no_ground.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class GroundEaterEnemy extends BaseEnemy {
  GroundEaterEnemy({super.key})
    : super(
        name: "GroundEater",
        enemyState: EnemyState(health: 10),
        state: InfinityObjectState(color: Colors.deepPurpleAccent),
      );

  @override
  void onCollisionEvent(CollisionEvent event) {
    if (event.other.object.name == "Shooter") {
      event.other.object.addLoop(
        NoGround(
          parent: event.other.object,
          target: InfinityEngine.getObjectByName("Ground")!,
        ),
      );
    }
    super.onCollisionEvent(event);
  }
}
