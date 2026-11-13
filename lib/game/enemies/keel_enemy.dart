import 'dart:ui';

import 'package:infinity_engine/game/effects/gravity_up.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';

class KeelEnemy extends BaseEnemy {
  KeelEnemy({super.key})
    : super(
        name: "Keel",
        enemyState: (EnemyState(health: 10, speed: 200)),
        state: InfinityObjectState(color: const Color(0xFF00FF00)),
      );

  @override
  void onCollisionEvent(CollisionEvent event) {
    if (event.other.object.name == "Shooter") {
      event.other.object.addLoop(
        GravityUp(parent: event.other.object, target: event.other.object),
      );
    }
    super.onCollisionEvent(event);
  }
}
