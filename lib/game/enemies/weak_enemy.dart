import 'package:flutter/material.dart';
import 'package:infinity_engine/game/enemies/base_enemy.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

class WeakEnemy extends BaseEnemy {
  WeakEnemy({super.key})
    : super(
        name: 'Weak Enemy',
        enemyState: EnemyState(health: 100),
        state: InfinityObjectState(color: Colors.red, size: Vector2(60, 60)),
      );
}
