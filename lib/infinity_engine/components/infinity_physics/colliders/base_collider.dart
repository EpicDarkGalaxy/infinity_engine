import 'package:hit_them/infinity_engine/components/infinity_component.dart';
import 'package:hit_them/infinity_engine/components/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/components/infinity_object.dart';

abstract class BaseCollider extends InfinityComponent {
  final InfinityObject object;
  Vector2? size;
  Vector2 bounciness;

  BaseCollider({
    required this.object,
    this.size,
    this.bounciness = const Vector2(0, 0),
  }) {
    size ??= object.size;
  }

  // Dynamically resolve position from the parent object
  Vector2 get position => object.position;

  void overlaps(BaseCollider other);
}
