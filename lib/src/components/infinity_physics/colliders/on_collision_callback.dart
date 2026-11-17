import 'package:infinity_engine/src/components/infinity_physics/colliders/base_collider.dart';

/// Represents a collision event between two colliders.
class CollisionEvent {
  final BaseCollider other;
  final BaseCollider self;

  CollisionEvent({required this.other, required this.self});
}

/// A mixin that can be used to add collision callback functionality to an object.
mixin OnCollisionCallBack {
  /// A callback function that is called when a collision occurs between two colliders.
  void onCollisionEvent(CollisionEvent event) {
    // TODO: implement onCollision
  }
}
