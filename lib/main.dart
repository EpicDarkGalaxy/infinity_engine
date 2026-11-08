import 'package:hit_them/game/test.dart';
import 'package:hit_them/game/physiscs_test.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/singularity.dart';

import 'package:hit_them/infinity_engine/infinity_engine.dart';

void main() {
  final engine = InfinityEngine();
  engine.init();
  runApp(Singularity(rootLoop: HitThemGame()));
}

class HitThemGame extends SingularityLoop {
  @override
  void update(double dt) {}

  @override
  void start() {
    final testObject = InfinityObject(
      state: InfinityObjectState(name: "Spawner")..visible = false,
      loops: [PhysicsGame()],
    );
    InfinityEngine().addObject(testObject);
  }
}
