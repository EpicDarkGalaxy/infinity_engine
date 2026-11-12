import 'package:flutter/material.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

class ToughEnemy extends BaseEnemy {
  ToughEnemy({super.key})
    : super(
        name: "Tough Enemy",
        enemyState: EnemyState(health: 150),
        state: InfinityObjectState(color: Colors.white, size: Vector2(40, 40)),
      );
}
