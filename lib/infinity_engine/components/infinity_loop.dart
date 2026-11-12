mixin InfinityLoop {
  /// Called every frame by InfinityTick's logic tick
  void update(double dt);

  /// Called before the next frame once
  void start();
}
