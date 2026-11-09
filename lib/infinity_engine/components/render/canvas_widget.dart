import 'package:flutter/material.dart';

/// 1. Controller to manage canvas objects reactively
class CanvasController extends ChangeNotifier {
  final Map<int, List<Widget>> _objects =
      {}; // z-indexed objects for rendering order

  List<Widget> get objects {
    final zIndices = _objects.keys.toList()..sort();
    return List.unmodifiable(zIndices.expand((zIndex) => _objects[zIndex]!));
  }

  void addObject(int zIndex, Widget object) {
    _objects.putIfAbsent(zIndex, () => []).add(object);
    notifyListeners(); // Automatically tells the canvas to redraw
  }

  void removeObject(int zIndex, Widget object) {
    _objects[zIndex]?.remove(object);
    notifyListeners();
  }
}

// The Canvas Widget listens to the controller
class CanvasWidget extends StatelessWidget {
  const CanvasWidget({super.key, required this.controller});

  final CanvasController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        debugPrint("Rendering ${controller.objects.length} objects on canvas");
        return Stack(children: controller.objects);
      },
    );
  }
}
