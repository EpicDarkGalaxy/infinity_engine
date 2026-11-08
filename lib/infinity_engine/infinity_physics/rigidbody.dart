import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/infinity_physics/aabb.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_component.dart';

class RigidBody extends InfinityComponent {
  RigidBody({
    required this.object,
    this.mass = 1.0,
    this.drag = 0.0005, // Controls air resistance strength
    this.isStatic = false,
  }) : invMass = (mass == 0 || isStatic) ? 0.0 : (1.0 / mass);

  final InfinityObject object;
  final double mass;
  final double invMass;
  final bool isStatic;
  final double drag;

  Vector2 velocity = Vector2.zero;
  Vector2 acceleration = Vector2.zero;
  Vector2 _forceAccumulator = Vector2.zero;

  void addForce(Vector2 force) {
    _forceAccumulator = _forceAccumulator + force;
  }

  @override
  void apply(double dt) {}
}
