import 'package:flutter/widgets.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_component.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/on_collision_callback.dart';

abstract class BaseCollider extends InfinityComponent {
  final InfinityObject object;
  Vector2? size;
  Vector2 bounciness;
  final List<InfinityLayer> ignore;
  final void Function(BaseCollider other)? onCollision;

  BaseCollider({
    required this.object,
    this.size,
    this.bounciness = const Vector2(0, 0),
    this.onCollision,
    this.ignore = const [],
  }) {
    size ??= object.size;
  }

  // Dynamically resolve position from the parent object
  Vector2 get position => object.position;

  (bool, BaseCollider?) hasCollider(InfinityObject other) {
    for (InfinityComponent component in other.components) {
      if (component is BaseCollider) {
        return (true, component);
      }
    }
    return (false, null);
  }

  bool canCollide(BaseCollider other) {
    if (ignore.contains(other.object.layer) ||
        other.ignore.contains(object.layer) ||
        !object.layer.isCollidable ||
        !other.object.layer.isCollidable) {
      return false;
    }
    return true;
  }

  @mustCallSuper
  void overlaps(BaseCollider other) {
    final collisionEvent = CollisionEvent(self: this, other: other);
    if (object is OnCollisionCallBack) {
      // Check if the object itself is OnCollisionCallBack
      (object as OnCollisionCallBack).onCollisionEvent(collisionEvent);
    } else {
      // Check if any of the loops are OnCollisionCallBack
      for (final loop in object.loops) {
        if (loop is OnCollisionCallBack) {
          (loop as OnCollisionCallBack).onCollisionEvent(collisionEvent);
        }
      }
    }

    // Calling other object's onCollisionEvent,
    // This is because the collision is already resolved and
    // the other object is not colliding with this object
    if (other.object is OnCollisionCallBack) {
      // Check if the other object itself is OnCollisionCallBack
      (other.object as OnCollisionCallBack).onCollisionEvent(
        CollisionEvent(self: other, other: this),
      );
    } else {
      // Check if any of the other object's loops are OnCollisionCallBack
      for (final loop in other.object.loops) {
        if (loop is OnCollisionCallBack) {
          (loop as OnCollisionCallBack).onCollisionEvent(
            CollisionEvent(self: other, other: this),
          );
        }
      }
    }
    other.onCollision?.call(this);
    onCollision?.call(other);
  }

  @override
  Future<void> collideWith(InfinityObject other) async {
    for (InfinityComponent component in other.components) {
      if (component is BaseCollider) {
        overlaps(component);
      }
    }
  }
}
