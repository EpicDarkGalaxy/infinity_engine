import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/game/player.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_input/input_listener.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/aabb.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';

void main() {
  testWidgets('jumps from a ground callback without generic collision state', (
    tester,
  ) async {
    final playerObject = InfinityObject(
      state: InfinityObjectState(name: 'Player'),
    );
    final body = RigidBody(object: playerObject, useGravity: false);
    final player = Player(shooter: playerObject, shooterBody: body);
    final playerCollider = AABBCollider(object: playerObject);
    final groundCollider = AABBCollider(
      object: InfinityObject(state: InfinityObjectState(name: 'Ground')),
    );

    player.onCollisionEvent(
      CollisionEvent(self: playerCollider, other: groundCollider),
    );

    await tester.pumpWidget(
      const MaterialApp(home: InputListener(child: SizedBox.expand())),
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);

    player.update(1 / 60);

    expect(body.velocity.y, lessThan(0));
  });
}
