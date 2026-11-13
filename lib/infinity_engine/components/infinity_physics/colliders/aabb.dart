import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/base_collider.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/resolvers/aabb_collision_resolver.dart';

class AABBCollider extends BaseCollider {
  /// - [object] is the parent object of this collider
  /// - [size] is the size of the collider, if null, it will be the same as the parent object
  /// - [onCollision] is the function that will be called when the collider collides with another collider
  /// - [bounciness] is the bounciness of the collider, if null, it will be 0
  /// - [ignore] is the list of layers that this collider will ignore
  AABBCollider({
    required super.object,
    super.size,
    super.onCollision,
    super.bounciness,
    super.ignore,
  });

  @override
  void overlaps(BaseCollider other) {
    if (!canCollide(other)) return;

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
}
