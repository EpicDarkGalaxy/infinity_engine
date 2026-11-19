import 'package:flutter/material.dart';
import 'package:infinity_engine/src/components/infinity_component.dart';
import 'package:infinity_engine/src/components/infinity_math/vector2.dart';
import 'package:infinity_engine/src/components/infinity_loop.dart';
import 'package:infinity_engine/src/components/infinity_layer.dart';
import 'package:infinity_engine/src/infinity_engine.dart';
import 'package:collection/collection.dart';

/// A class that holds the state of an [InfinityObject].
/// This class is used to track the state of an [InfinityObject] and to notify
/// the [InfinityEngine] when the state of an [InfinityObject] changes.
class InfinityObjectState extends ChangeNotifier {
  final String id;

  String name;

  BoxShape _shape;
  InfinityLayer _layer;

  bool _hidden = false;
  bool _hasPendingChanges = false;
  bool isColliding = false;

  // Position tracking
  Vector2 previousPosition;
  Vector2 currentPosition;

  // Size tracking
  Vector2 previousSize;
  Vector2 currentSize;

  // Color tracking
  Color previousColor;
  Color currentColor;

  // Rotation tracking
  double previousRotation = 0.0;
  double currentRotation = 0.0;

  /// Creates a new [InfinityObjectState] with the given parameters.
  /// ## Parameters
  /// - [id] is a unique identifier for the object.
  /// - [position] is the initial position of the object.
  /// - [size] is the initial size of the object.
  /// - [rotation] is the initial rotation of the object.
  /// - [color] is the initial color of the object.
  /// - [layer] is the initial layer of the object (defaults to the default layer).
  InfinityObjectState({
    this.id =
        "100", // Currently not used, but can be used for future features like object serialization or identification
    Vector2 position = Vector2.zero,
    Vector2 size = const Vector2(100, 100),
    double rotation = 0.0,
    Color color = Colors.red,
    InfinityLayer? layer,
    this._shape = BoxShape.rectangle,
    this.name = "New InfinityObject",
  }) : _layer = layer ?? InfinityLayer.defaultLayer,
       previousPosition = position,
       currentPosition = position,
       previousSize = size,
       currentSize = size,
       previousRotation = rotation,
       currentRotation = rotation,
       previousColor = color,
       currentColor = color;

  // Getters for current values
  Vector2 get position => currentPosition;
  Vector2 get size => currentSize;
  double get rotation => currentRotation;
  Color get color => currentColor;
  InfinityLayer get layer => _layer;
  BoxShape get shape => _shape;
  bool get visibility => !_hidden;

  // Setters that automatically cache previous values for smooth transitions
  set position(Vector2 newPos) {
    if (!_sameVector(currentPosition, newPos)) {
      previousPosition = currentPosition;
      currentPosition = newPos;
      _hasPendingChanges = true;
    }
  }

  set size(Vector2 newSize) {
    if (!_sameVector(currentSize, newSize)) {
      previousSize = currentSize;
      currentSize = newSize;
      _hasPendingChanges = true;
    }
  }

  set rotation(double newRotation) {
    if (currentRotation != newRotation) {
      previousRotation = currentRotation;
      currentRotation = newRotation;
      _hasPendingChanges = true;
    }
  }

  set color(Color newColor) {
    if (currentColor != newColor) {
      previousColor = currentColor;
      currentColor = newColor;
      _hasPendingChanges = true;
    }
  }

  set layer(InfinityLayer newLayer) {
    if (!identical(_layer, newLayer)) {
      _layer = newLayer;
      notifyListeners();
    }
  }

  set visibility(bool isVisible) {
    if (visibility == isVisible) return;
    _hidden = !isVisible;
    notifyListeners();
  }

  set shape(BoxShape shape) {
    if (shape != _shape) {
      _shape = shape;
    }
  }

  void update() {
    if (!_hasPendingChanges) return;
    _hasPendingChanges = false;
    notifyListeners();
  }

  // Check if two vectors are the same, used to check if the position or size has changed to avoid unnecessary updates
  bool _sameVector(Vector2 first, Vector2 second) =>
      first.x == second.x && first.y == second.y;
}

/// A widget that represents an object game object in the engine.
/// ## Note:
/// InfinityObject is a [StatelessWidget] that listens to the [InfinityObjectState] and rebuilds itself when the state changes. It is not meant to be modified directly, but rather through the state object.
class InfinityObject extends StatelessWidget {
  /// A widget that represents an object game object in the engine.
  /// ### Parameters
  /// * [state] - The state of the object, if not provided, a new state will be created.
  /// * [loops] - The loops that are attached to this object (or scripts that extends [InfinityLoop]).
  InfinityObject({
    super.key,
    InfinityObjectState? state,
    List<InfinityLoop>? loops,
  }) {
    state ??= InfinityObjectState();
    this.state = state;
    if (loops != null) {
      _loops.addAll(loops);
    }
  }

  late final InfinityObjectState state;
  // Loops: They are scripts that are attached to this object and are called every frame by the engine.
  // They can be used to update the object's state, position, size, etc.
  // Loops are not meant to be modified directly, InfinityObject.addLoop
  final List<InfinityLoop> _loops = [];
  final List<InfinityComponent> _components =
      []; // Components that are attached to this object (eg. Collision, RigidBody)

  // Add Loop to object
  void addLoop(InfinityLoop loop) {
    _loops.add(loop);
    // Register start callback that will be called when the engine starts,
    // or if the engine is already running, called immediately.
    InfinityEngine.addStartCallback(loop.start);
  }

  void removeLoop(InfinityLoop loop) {
    _loops.remove(loop);
  }

  // Proxy setter and getters for convenience if accessing via object reference
  // Setters
  set shape(BoxShape shape) {
    state.shape = shape;
  }

  set position(Vector2 newPosition) {
    state.position = newPosition;
  }

  set size(Vector2 newSize) {
    state.size = newSize;
  }

  set rotation(double newRotation) {
    state.rotation = newRotation;
  }

  set color(Color newColor) {
    state.color = newColor;
  }

  set visibility(bool isVisible) {
    state.visibility = isVisible;
  }

  set isColliding(bool isColliding) {
    state.isColliding = isColliding;
  }

  set layer(InfinityLayer newLayer) {
    state.layer = newLayer;
    // InfinityEngine.setObjectLayer(this, newLayer);
  }

  // Getters
  String get name => state.name;
  BoxShape get shape => state.shape;
  Vector2 get position => state.position;
  Vector2 get size => state.size;
  double get rotation => state.rotation;
  Color get color => state.color;
  InfinityLayer get layer => state.layer;
  bool get visibility => state.visibility;
  bool get isColliding => state.isColliding;
  List<InfinityComponent> get components => _components;

  /// Loops are not meant to be modified directly, InfinityObject.addLoop
  List<InfinityLoop> get loops => List.unmodifiable(_loops);

  T? getComponent<T extends InfinityComponent>() {
    return _components.firstWhereOrNull((component) => component is T) as T?;
  }

  void removeComponent(InfinityComponent component) {
    _components.remove(component);
  }

  void addComponent(InfinityComponent component) {
    _components.add(component);
  }

  void addComponents(List<InfinityComponent> component) {
    _components.addAll(component);
  }

  // Flushes batched visual changes on the render tick.
  void refresh() {
    state.update();
  }

  void hide() {
    state.visibility = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([state, layer]),
      builder: (context, child) {
        if (!state.visibility || !layer.isVisible) {
          return const SizedBox.shrink();
        }
        return Transform.translate(
          offset: state.position.toOffset,
          child: Transform.rotate(
            angle: state.rotation,
            child: Container(
              width: state.size.toSize.width,
              height: state.size.toSize.height,
              decoration: BoxDecoration(shape: state.shape, color: state.color),
            ),
          ),
        );
      },
    );
  }
}
