import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_component.dart';

/// A RigidBody component that can be attached to an InfinityObject to enable physics simulation.
/// This component handles forces, acceleration, velocity, and position updates based on the physics simulation.
/// ## Parameters
/// - [object] is the parent InfinityObject to which this RigidBody is attached.
/// - [mass] is the mass of the object. A mass of 0 or if [isStatic] is true will make the object immovable.
/// - [drag] is the drag coefficient that slows down the object over time.
/// - [isStatic] determines if the object is static (immovable) or dynamic (movable).
/// - [manualTrigger] if true, the physics simulation will not automatically update the object's position and velocity; you must call [applyForce] manually.
/// - [useGravity] if true, the object will be affected by gravity.
class RigidBody extends InfinityComponent {
  RigidBody({
    required this.object,
    this.mass = 1.0,
    this.drag = 0.0005,
    this.gravityScale = 1.0,
    this.isStatic = false,
    this.manualTrigger = false,
    this.useGravity = true,
  }) : invMass = (mass == 0 || isStatic) ? 0.0 : (1.0 / mass);

  final InfinityObject object;
  final double mass;
  final double invMass;
  final bool isStatic;
  final double drag;
  double gravityScale;
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

  /// Applies an impulse to the rigid body.
  void addImpulse(Vector2 impulse) {
    velocity = velocity + impulse * invMass;
  }

  /// Applies an acceleration to the rigid body.
  void applyAcceleration(Vector2 acceleration) {
    velocity = velocity + acceleration;
    velocity = velocity * (1.0 - (drag * invMass));
  }

  /// Applies accumulated forces, gravity, and integrates motion.
  void applyForce(double dt) {
    if (invMass == 0) return; // Static bodies never move

    // Automatically add gravity force (F = m * g) if enabled
    if (useGravity) {
      _forceAccumulator =
          _forceAccumulator + Vector2(0, globalGravity * gravityScale * mass);
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
