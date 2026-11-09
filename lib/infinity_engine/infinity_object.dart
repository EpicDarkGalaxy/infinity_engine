import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity_component.dart';
import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/infinity_loop.dart';

class InfinityObjectState extends ChangeNotifier {
  final String id;
  final String name;
  final BoxShape _shape;

  bool hidden = false;

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
    this._shape = BoxShape.rectangle,
    this.name = "New InfinityObject",
  }) : previousPosition = position,
       currentPosition = position,
       previousSize = size,
       currentSize = size,
       previousRotation = rotation,
       currentRotation = rotation,
       previousColor = color,
       currentColor = color;

  Vector2 get position => currentPosition;
  Vector2 get size => currentSize;
  double get rotation => currentRotation;
  Color get color => currentColor;
  BoxShape get shape => _shape;
  bool get visible => !hidden;

  // Setters that automatically cache previous values for smooth transitions
  set position(Vector2 newPos) {
    if (currentPosition != newPos) {
      previousPosition = currentPosition;
      currentPosition = newPos;
    }
  }

  set size(Vector2 newSize) {
    if (currentSize != newSize) {
      previousSize = currentSize;
      currentSize = newSize;
    }
  }

  set rotation(double newRotation) {
    if (currentRotation != newRotation) {
      previousRotation = currentRotation;
      currentRotation = newRotation;
    }
  }

  set color(Color newColor) {
    if (currentColor != newColor) {
      previousColor = currentColor;
      currentColor = newColor;
    }
  }

  set visible(bool isVisible) {
    hidden = !isVisible;
  }

  void update() {
    notifyListeners();
  }
}

class InfinityObject extends StatelessWidget {
  InfinityObject({super.key, required this.state, this.loops});

  final InfinityObjectState state;
  final List<InfinityLoop>? loops; // Scripts that are attached to this object
  final List<InfinityComponent> _components = []; // Components that are attached to this object (eg. Collision, RigidBody)

  // Proxy setter for convenience if accessing via object reference
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

  set visible(bool isVisible) {
    state.visible = isVisible;
  }

  // Getters
  Vector2 get position => state.position;
  Vector2 get size => state.size;
  double get rotation => state.rotation;
  Color get color => state.color;
  bool get visible => state.hidden;
  List<InfinityComponent> get components => _components;

  void removeComponent(InfinityComponent component) {
    _components.remove(component);
  }

  void addComponent(InfinityComponent component) {
    _components.add(component);
  }

  void addComponents(List<InfinityComponent> component) {
    _components.addAll(component);
  }

  // Force update, Called by InfinityTick's RenderTick
  void update() {
    state.update();
  }

  @override
  Widget build(BuildContext context) {
    if (state.hidden) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
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
