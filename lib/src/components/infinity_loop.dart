/// A mixin that allows a class to be used in an InfinityLoop.
/// This mixin is used by InfinityTick to update the game logic.
/// ## Note:
/// Its methods are called only if the extending class is an InfinityObject and is registered in the engine,
/// or if it is a part another registered InfinityObject's loop registry.
mixin InfinityLoop {
  /// Called every frame by InfinityTick's logic tick
  void update(double dt);

  /// Called once before the next frame
  void start();
}
