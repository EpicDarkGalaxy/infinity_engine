import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';

class AABB {
  AABB({required this.min, required this.max});

  final Vector2 min; // Top-left
  final Vector2 max; // Bottom-right

  // Factory constructor from position and size
  factory AABB.fromPositionSize(Vector2 pos, double width, double height) {
    return AABB(min: pos, max: Vector2(pos.x + width, pos.y + height));
  }

  // Check if this box overlaps with another box
  bool overlaps(AABB other) {
    return max.x > other.min.x &&
        min.x < other.max.x &&
        max.y > other.min.y &&
        min.y < other.max.y;
  }
}
