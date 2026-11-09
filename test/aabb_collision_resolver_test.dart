import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/aabb.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/resolvers/aabb_collision_resolver.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/rigidbody.dart';

void main() {
  group('AABBCollisionResolver', () {
    test('does nothing when neither object has a rigid body', () {
      final objectA = _objectAt(0, 0);
      final objectB = _objectAt(8, 0);

      AABBCollisionResolver.resolve(
        objectA,
        objectB,
        AABBCollider(object: objectA),
        AABBCollider(object: objectB),
        const Vector2(0.5, 0.5),
      );

      _expectVector(objectA.position, const Vector2(0, 0));
      _expectVector(objectB.position, const Vector2(8, 0));
    });

    test('does nothing when the colliders do not overlap', () {
      final objectA = _objectAt(0, 0);
      final objectB = _objectAt(11, 0);
      final bodyA = _addBody(objectA);
      final bodyB = _addBody(objectB);
      bodyA.velocity = const Vector2(3, 0);
      bodyB.velocity = const Vector2(-2, 0);

      AABBCollisionResolver.resolve(
        objectA,
        objectB,
        AABBCollider(object: objectA),
        AABBCollider(object: objectB),
        const Vector2(0.5, 0.5),
      );

      _expectVector(objectA.position, const Vector2(0, 0));
      _expectVector(objectB.position, const Vector2(11, 0));
      _expectVector(bodyA.velocity, const Vector2(3, 0));
      _expectVector(bodyB.velocity, const Vector2(-2, 0));
    });

    test('separates a horizontal collision by inverse mass and bounces', () {
      final objectA = _objectAt(0, 0);
      final objectB = _objectAt(8, 0);
      final bodyA = _addBody(objectA, mass: 1);
      final bodyB = _addBody(objectB, mass: 3);
      bodyA.velocity = const Vector2(4, 2);
      bodyB.velocity = const Vector2(-2, -1);

      AABBCollisionResolver.resolve(
        objectA,
        objectB,
        AABBCollider(object: objectA),
        AABBCollider(object: objectB),
        const Vector2(0.5, 0.25),
      );

      expect(objectA.position.x, closeTo(-1.5, 1e-10));
      expect(objectB.position.x, closeTo(8.5, 1e-10));
      expect(objectA.position.y, 0);
      expect(objectB.position.y, 0);
      _expectVector(bodyA.velocity, const Vector2(-2, 2));
      _expectVector(bodyB.velocity, const Vector2(1, -1));
    });

    test('uses the vertical axis when vertical overlap is smaller', () {
      final objectA = _objectAt(0, 0);
      final objectB = _objectAt(2, 8);
      final bodyA = _addBody(objectA);
      final bodyB = _addBody(objectB);
      bodyA.velocity = const Vector2(1, 4);
      bodyB.velocity = const Vector2(-1, -6);

      AABBCollisionResolver.resolve(
        objectA,
        objectB,
        AABBCollider(object: objectA),
        AABBCollider(object: objectB),
        const Vector2(0.5, 0.5),
      );

      _expectVector(objectA.position, const Vector2(0, -1));
      _expectVector(objectB.position, const Vector2(2, 9));
      _expectVector(bodyA.velocity, const Vector2(1, -2));
      _expectVector(bodyB.velocity, const Vector2(-1, 3));
    });

    test('moves only the dynamic object when colliding with a static body', () {
      final objectA = _objectAt(0, 0);
      final objectB = _objectAt(8, 0);
      final bodyA = _addBody(objectA, isStatic: true);
      final bodyB = _addBody(objectB);
      bodyA.velocity = const Vector2(2, 0);
      bodyB.velocity = const Vector2(-4, 0);

      AABBCollisionResolver.resolve(
        objectA,
        objectB,
        AABBCollider(object: objectA),
        AABBCollider(object: objectB),
        const Vector2(0.25, 0.5),
      );

      _expectVector(objectA.position, const Vector2(0, 0));
      _expectVector(objectB.position, const Vector2(10, 0));
      _expectVector(bodyA.velocity, const Vector2(2, 0));
      _expectVector(bodyB.velocity, const Vector2(1, 0));
    });
  });
}

InfinityObject _objectAt(double x, double y) => InfinityObject(
  state: InfinityObjectState(
    position: Vector2(x, y),
    size: const Vector2(10, 10),
  ),
);

RigidBody _addBody(
  InfinityObject object, {
  double mass = 1,
  bool isStatic = false,
}) {
  final body = RigidBody(
    object: object,
    mass: mass,
    isStatic: isStatic,
    useGravity: false,
  );
  object.addComponent(body);
  return body;
}

void _expectVector(Vector2 actual, Vector2 expected) {
  expect(actual.x, closeTo(expected.x, 1e-10));
  expect(actual.y, closeTo(expected.y, 1e-10));
}
