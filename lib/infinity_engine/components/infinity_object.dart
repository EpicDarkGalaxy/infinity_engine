import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_component.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_loop.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_layer.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';
import 'package:collection/collection.dart';

class InfinityObjectState extends ChangeNotifier {
  final String id;
  final BoxShape _shape;

  String name;

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

  InfinityObjectState({
    this.id = " f",
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

  void update() {
    if (!_hasPendingChanges) return;
    _hasPendingChanges = false;
    notifyListeners();
  }

  bool _sameVector(Vector2 first, Vector2 second) =>
      first.x == second.x && first.y == second.y;
}

class InfinityObject extends StatelessWidget {
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
  final List<InfinityLoop> _loops =
      []; // Scripts that are attached to this object
  final List<InfinityComponent> _components = []; // Components that are attached to this object (eg. Collision, RigidBody)

  // Add Loop to object
  void addLoop(InfinityLoop loop) {
    _loops.add(loop);
    InfinityEngine.addStartCallback(loop.start);
  }

  void removeLoop(InfinityLoop loop) {
    _loops.remove(loop);
  }

  // Proxy setter and getters for convenience if accessing via object reference
  // Setters
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
    InfinityEngine.setObjectLayer(this, newLayer);
  }

  // Getters
  String get name => state.name;
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
      listenable: state,
      builder: (context, child) {
        if (!state.visibility) return const SizedBox.shrink();
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
