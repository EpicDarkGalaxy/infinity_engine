import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_component.dart';

class RigidBody extends InfinityComponent {
  RigidBody({
    required this.object,
    this.mass = 1.0,
    this.drag = 0.0005,
    this.isStatic = false,
    this.manualTrigger = false,
    this.useGravity = true,
  }) : invMass = (mass == 0 || isStatic) ? 0.0 : (1.0 / mass);

  final InfinityObject object;
  final double mass;
  final double invMass;
  final bool isStatic;
  final double drag;
  bool manualTrigger;
  bool useGravity;

  // Standard 2D pixel gravity (e.g., 980 px/s²)
  static double globalGravity = 980.0;

  Vector2 velocity = Vector2.zero;
  Vector2 acceleration = Vector2.zero;
  Vector2 _forceAccumulator = Vector2.zero;

  Vector2 get accumulatedForce => _forceAccumulator;

  /// Adds a force to the rigid body.
  void addForce(Vector2 force) {
    _forceAccumulator = _forceAccumulator + force;
  }

  /// Applies accumulated forces, gravity, and integrates motion.
  void applyForce(double dt) {
    if (invMass == 0) return; // Static bodies never move

    // Automatically add gravity force (F = m * g) if enabled
    if (useGravity) {
      _forceAccumulator = _forceAccumulator + Vector2(0, globalGravity * mass);
    }

    // F = ma -> a = F * invMass
    acceleration = _forceAccumulator * invMass;
    velocity = velocity + acceleration * dt;

    // Apply drag
    velocity = velocity * (1.0 - (drag * invMass) * dt);

    // Update position
    object.position = object.position + velocity * dt;

    // Reset accumulator for the next frame
    _forceAccumulator = Vector2.zero;
  }

  @override
  void apply(double dt) {
    if (manualTrigger || isStatic) {
      return;
    }
    applyForce(dt);
  }
}
