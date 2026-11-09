import 'package:hit_them/infinity_engine/components/infinity_object.dart';
import 'package:hit_them/infinity_engine/components/infinity_physics/colliders/base_collider.dart';
import 'package:hit_them/infinity_engine/components/infinity_physics/resolvers/aabb_collision_resolver.dart';

class AABBCollider extends BaseCollider {
  /// - [object] is the parent object of this collider
  /// - [size] is the size of the collider, if null, it will be the same as the parent object
  AABBCollider({
    required super.object,
    super.size,
    this.onCollision,
    super.bounciness,
  });

  final void Function(InfinityObject other)? onCollision;

  @override
  void overlaps(BaseCollider other) {
    if (object.layer.zIndex != other.object.layer.zIndex) {
      return; // Only check collisions within the same layer
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
    if (isColliding) {
      // Automatically resolve position and velocity
      AABBCollisionResolver.resolve(
        object,
        other.object,
        this,
        other,
        bounciness,
      );
      if (onCollision != null) onCollision!(other.object);
    }
  }

  @override
  void apply(double dt) {}
}
