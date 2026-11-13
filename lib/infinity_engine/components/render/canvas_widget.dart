import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';

/// 1. Controller to manage canvas objects reactively
class CanvasController extends ChangeNotifier {
  final Map<int, List<Widget>> _objects =
      {}; // z-indexed objects for rendering order
  List<Widget>? _orderedObjects;
  Size _canvasSize = Size.zero;

  List<Widget> get objects {
    final cachedObjects = _orderedObjects;
    if (cachedObjects != null) return cachedObjects;

    final zIndices = _objects.keys.toList()..sort();
    _orderedObjects = List.unmodifiable(
      zIndices.expand((zIndex) => _objects[zIndex]!),
    );
    return _orderedObjects!;
  }

  void addObject(int zIndex, Widget object) {
    final layerObjects = _objects.putIfAbsent(zIndex, () => []);
    if (layerObjects.contains(object)) return;
    layerObjects.add(object);
    _orderedObjects = null;
    notifyListeners();
  }

  void removeObject(int zIndex, Widget object) {
    final layerObjects = _objects[zIndex];
    if (layerObjects == null || !layerObjects.remove(object)) return;
    if (layerObjects.isEmpty) _objects.remove(zIndex);
    _orderedObjects = null;
    notifyListeners();
  }

  void setCanvasSize(Size size) {
    if (size.width.isFinite && size.height.isFinite) {
      _canvasSize = size;
    }
  }

  Vector2 getCanvasSize() {
    return Vector2(_canvasSize.width, _canvasSize.height);
  }
}

// The Canvas Widget listens to the controller
class CanvasWidget extends StatelessWidget {
  const CanvasWidget({super.key, required this.controller});

  final CanvasController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        controller.setCanvasSize(constraints.biggest);
        return ListenableBuilder(
          listenable: controller,
          builder: (context, child) => Stack(children: controller.objects),
        );
      },
    );
  }
}
