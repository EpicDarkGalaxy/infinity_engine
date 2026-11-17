import 'package:flutter/material.dart';
import 'package:infinity_engine/src/components/infinity_layer.dart';
import 'package:infinity_engine/src/components/infinity_math/vector2.dart';

/// 1. Controller to manage canvas objects reactively
class CanvasController extends ChangeNotifier {
  Size _canvasSize = Size.zero;

  CanvasController() {
    InfinityLayer.sceneChanges.addListener(_onSceneChanged);
  }

  List<Widget> get objects {
    final List<Widget> objects = [];
    for (var layer in InfinityLayer.visibleLayers) {
      objects.addAll(layer.objects);
    }
    return objects;
  }

  void _onSceneChanged() => notifyListeners();

  @override
  void dispose() {
    InfinityLayer.sceneChanges.removeListener(_onSceneChanged);
    super.dispose();
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
    return ListenableBuilder(
      listenable: controller,
      builder: (context, widget) {
        return LayoutBuilder(
          builder: (context, constraints) {
            controller.setCanvasSize(constraints.biggest);
            return ListenableBuilder(
              listenable: controller,
              builder: (context, child) => Stack(children: controller.objects),
            );
          },
        );
      },
    );
  }
}
