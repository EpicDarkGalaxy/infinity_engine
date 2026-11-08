import 'package:hit_them/game/test.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity/singularity.dart';

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
      loops: [Game()],
    );
    InfinityEngine().addObject(testObject);
  }
}
