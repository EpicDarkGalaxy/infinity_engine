import 'dart:math' as math;

import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/infinity_physics/colliders/base_collider.dart';
import 'package:hit_them/infinity_engine/infinity_physics/rigidbody.dart';

class AABBCollisionResolver {
  /// Resolves AABB collision between two objects, correcting positions and bouncing velocities.
  static void resolve(
    InfinityObject objA,
    InfinityObject objB,
    BaseCollider colA,
    BaseCollider colB,
    Vector2 bounciness,
  ) {
    final bodyA = objA.components.whereType<RigidBody>().firstOrNull;
    final bodyB = objB.components.whereType<RigidBody>().firstOrNull;

    // If both are static or have no physics body, nothing to resolve
    if ((bodyA == null || bodyA.isStatic) &&
        (bodyB == null || bodyB.isStatic)) {
      return;
    }

    // 1. Calculate bounds
    final double leftA = colA.position.x;
    final double rightA = colA.position.x + colA.size!.x;
    final double topA = colA.position.y;
    final double bottomA = colA.position.y + colA.size!.y;

    final double leftB = colB.position.x;
    final double rightB = colB.position.x + colB.size!.x;
    final double topB = colB.position.y;
    final double bottomB = colB.position.y + colB.size!.y;

    // 2. Check overlap depths on X and Y axes
    final double overlapX = math.min(rightA, rightB) - math.max(leftA, leftB);
    final double overlapY = math.min(bottomA, bottomB) - math.max(topA, topB);

    if (overlapX <= 0 || overlapY <= 0) return;

    // 3. Resolve along the axis of least penetration
    if (overlapX < overlapY) {
      // Horizontal collision (Walls)
      final double direction = (leftA < leftB) ? -1.0 : 1.0;
      _resolveX(objA, objB, bodyA, bodyB, overlapX * direction, bounciness.x);
    } else {
      // Vertical collision (Floor / Ceiling)
      final double direction = (topA < topB) ? -1.0 : 1.0;
      _resolveY(objA, objB, bodyA, bodyB, overlapY * direction, bounciness.y);
    }
  }

  static void _resolveX(
    InfinityObject objA,
    InfinityObject objB,
    RigidBody? bodyA,
    RigidBody? bodyB,
    double penetration,
    double bounciness,
  ) {
    final invMassA = bodyA?.invMass ?? 0.0;
    final invMassB = bodyB?.invMass ?? 0.0;
    final totalInvMass = invMassA + invMassB;

    if (totalInvMass == 0) return;

    // Positional separation based on mass ratio
    if (invMassA > 0) {
      objA.position = Vector2(
        objA.position.x + penetration * (invMassA / totalInvMass),
        objA.position.y,
      );
    }
    if (invMassB > 0) {
      objB.position = Vector2(
        objB.position.x - penetration * (invMassB / totalInvMass),
        objB.position.y,
      );
    }

    // Velocity bounce (Restitution coefficient e.g., 0.1 for slight elasticity)
    double restitution = bounciness;
    if (bodyA != null && !bodyA.isStatic) {
      bodyA.velocity = Vector2(
        -bodyA.velocity.x * restitution,
        bodyA.velocity.y,
      );
    }
    if (bodyB != null && !bodyB.isStatic) {
      bodyB.velocity = Vector2(
        -bodyB.velocity.x * restitution,
        bodyB.velocity.y,
      );
    }
  }

  static void _resolveY(
    InfinityObject objA,
    InfinityObject objB,
    RigidBody? bodyA,
    RigidBody? bodyB,
    double penetration,
    double bounciness,
  ) {
    final invMassA = bodyA?.invMass ?? 0.0;
    final invMassB = bodyB?.invMass ?? 0.0;
    final totalInvMass = invMassA + invMassB;

    if (totalInvMass == 0) return;

    // Positional separation
    if (invMassA > 0) {
      objA.position = Vector2(
        objA.position.x,
        objA.position.y + penetration * (invMassA / totalInvMass),
      );
    }
    if (invMassB > 0) {
      objB.position = Vector2(
        objB.position.x,
        objB.position.y - penetration * (invMassB / totalInvMass),
      );
    }

    // Velocity bounce with energy loss (Restitution)
    // 0.0 = dead stop, 0.3 = bounces back with 30% of impact speed, 1.0 = superball
    double restitution = bounciness;

    if (bodyA != null && !bodyA.isStatic) {
      if (bodyA.velocity.y > 0) {
        // Hitting floor from above: bounce upward while losing momentum
        bodyA.velocity = Vector2(
          bodyA.velocity.x,
          -bodyA.velocity.y * restitution,
        );
      } else {
        // Hitting ceiling from below
        bodyA.velocity = Vector2(
          bodyA.velocity.x,
          -bodyA.velocity.y * restitution,
        );
      }
    }

    if (bodyB != null && !bodyB.isStatic) {
      if (bodyB.velocity.y < 0) {
        bodyB.velocity = Vector2(
          bodyB.velocity.x,
          -bodyB.velocity.y * restitution,
        );
      } else {
        bodyB.velocity = Vector2(
          bodyB.velocity.x,
          -bodyB.velocity.y * restitution,
        );
      }
    }
  }
}
