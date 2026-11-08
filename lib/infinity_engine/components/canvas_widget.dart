import 'package:flutter/material.dart';

/// 1. Controller to manage canvas objects reactively
class CanvasController extends ChangeNotifier {
  final List<Widget> _objects = [];

  List<Widget> get objects => List.unmodifiable(_objects);

  void addObject(Widget object) {
    _objects.add(object);
    notifyListeners(); // Automatically tells the canvas to redraw
  }

  void removeObject(Widget object) {
    _objects.remove(object);
    notifyListeners();
  }
}

/// 2. The Canvas Widget listens to the controller
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
