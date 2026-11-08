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
  Size previousSize;
  Size currentSize;

  // Color tracking
  Color previousColor;
  Color currentColor;

  InfinityObjectState({
    this.id = " f",
    Vector2 position = Vector2.zero,
    Size size = const Size(100, 100),
    Color color = Colors.red,
    this._shape = BoxShape.rectangle,
    this.name = "New InfinityObject",
  }) : previousPosition = position,
       currentPosition = position,
       previousSize = size,
       currentSize = size,
       previousColor = color,
       currentColor = color;

  // Interpolated getters for smooth rendering
  Vector2 get position => currentPosition;
  Size get size => currentSize;
  Color get color => currentColor;
  BoxShape get shape => _shape;

  // Setters that automatically cache previous values for smooth transitions
  set position(Vector2 newPos) {
    if (currentPosition != newPos) {
      previousPosition = currentPosition;
      currentPosition = newPos;
      // notifyListeners();
    }
  }

  set size(Size newSize) {
    if (currentSize != newSize) {
      previousSize = currentSize;
      currentSize = newSize;
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
  final List<InfinityComponent> _components = [];

  // Proxy setter for convenience if accessing via object reference
  // Setters
  set position(Vector2 newPosition) {
    state.position = newPosition;
  }

  set size(Size newSize) {
    state.size = newSize;
  }

  set color(Color newColor) {
    state.color = newColor;
  }

  set visible(bool isVisible) {
    state.visible = isVisible;
  }

  // Getters
  Vector2 get position => state.position;
  Size get size => state.size;
  Color get color => state.color;
  bool get visible => state.hidden;
  List<InfinityComponent> get components => _components;

  void removeComponent(InfinityComponent component) {
    _components.remove(component);
  }

  void addComponent(InfinityComponent component) {
    _components.add(component);
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
          child: Container(
            width: state.size.width,
            height: state.size.height,
            decoration: BoxDecoration(shape: state.shape, color: state.color),
          ),
        );
      },
    );
  }
}
