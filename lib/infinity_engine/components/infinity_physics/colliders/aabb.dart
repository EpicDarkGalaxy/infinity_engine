import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/base_collider.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/resolvers/aabb_collision_resolver.dart';

class AABBCollider extends BaseCollider {
  /// - [object] is the parent object of this collider
  /// - [size] is the size of the collider, if null, it will be the same as the parent object
  AABBCollider({
    required super.object,
    super.size,
    super.onCollision,
    super.bounciness,
  });

  @override
  void overlaps(BaseCollider other) {
    if (object.layer.zIndex != other.object.layer.zIndex ||
        !object.layer.isCollidable && !other.object.layer.isCollidable) {
      return; // Only check collisions within the same layer or if both are collidable
    }

    // Check if the other collider is an AABBCollider
    final bool isCollidingX =
        position.x < other.position.x + other.size!.x &&
        position.x + size!.x > other.position.x;

    final bool isCollidingY =
        position.y < other.position.y + other.size!.y &&
        position.y + size!.y > other.position.y;

    final bool isColliding = (isCollidingX && isCollidingY);

    object.isColliding = isColliding;
    other.object.isColliding = isColliding;

    if (isColliding) {
      super.overlaps(other);
      // Automatically resolve position and velocity
      AABBCollisionResolver.resolve(
        object,
        other.object,
        this,
        other,
        bounciness,
      );
    }
  }

  @override
  void apply(double deltaTime) {
    // for (final collider in other.components) {
    //   if (collider is BaseCollider) {
    //     overlaps(collider);
    //   }
    // }
  }
}
