import 'package:infinity_engine/src/components/infinity_loop.dart';

/// A component that provides the delta time between frames.
class InfinityTime with InfinityLoop {
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
