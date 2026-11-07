import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';

class InfinityObjectState extends ChangeNotifier {
  final String id;
  final String name;
  final BoxShape _shape;

  bool hidden = false;

  // Position tracking
  Offset previousPosition;
  Offset currentPosition;

  // Size tracking
  Size previousSize;
  Size currentSize;

  // Color tracking
  Color previousColor;
  Color currentColor;

  InfinityObjectState({
    this.id = " f",
    Offset position = const Offset(0, 0),
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
  Offset get position => currentPosition;
  Size get size => currentSize;
  Color get color => currentColor;
  BoxShape get shape => _shape;

  // Setters that automatically cache previous values for smooth transitions
  set position(Offset newPos) {
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
      notifyListeners();
    }
  }

  set color(Color newColor) {
    if (currentColor != newColor) {
      previousColor = currentColor;
      currentColor = newColor;
      notifyListeners();
    }
  }

  void update() {
    notifyListeners();
  }
}

class InfinityObject extends StatelessWidget {
  const InfinityObject({super.key, required this.state, this.loops});

  final InfinityObjectState state;
  final List<InfinityLoop>? loops;

  // Proxy setter for convenience if updating via object reference
  set position(Offset newPosition) {
    state.position = newPosition;
  }

  void hide() {
    state.hidden = true;
  }

  @override
  Widget build(BuildContext context) {
    if (state.hidden) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        return Transform.translate(
          offset: state.position,
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
