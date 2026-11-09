import 'package:hit_them/infinity_engine/components/infinity_loop.dart';

class InfinityTime extends InfinityLoop {
  static double get deltaTime => _deltaTime;
  static double _deltaTime = 0.0;

  @override
  void update(double dt) {
    _deltaTime = dt;
  }

  @override
  void start() {}

  static double get time => _deltaTime;
}
