import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/base_collider.dart';

class CollisionEvent {
  final BaseCollider other;
  final BaseCollider self;

  CollisionEvent({required this.other, required this.self});
}

mixin OnCollisionCallBack {
  void onCollisionEvent(CollisionEvent event) {
    // TODO: implement onCollision
  }
}
