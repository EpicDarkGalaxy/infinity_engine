import 'package:flutter/material.dart';
import 'package:infinity_engine/components.dart';
import 'package:infinity_engine/src/components/infinity_log.dart';

/// 1. Controller to manage canvas objects reactively
class CanvasController extends ChangeNotifier {
  Size _canvasSize = Size.zero;

  List<Widget> get objects {
    final List<Widget> objects = [];
    final scene = InfinitySceneManager().currentScene;
    if (scene == null) return objects;

    void addVisibleLayerObjects(InfinityLayer layer) {
      if (!layer.isVisible) return;
      objects.addAll(layer.objects);
      for (final subLayer in layer.subLayer) {
        addVisibleLayerObjects(subLayer);
      }
    }

    for (final layer in scene.layers) {
      addVisibleLayerObjects(layer);
    }
    InfinityLog.d('CanvasController SceneChanged: ${objects.length} objects');
    return objects;
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
    final sceneManager = InfinitySceneManager();
    return ListenableBuilder(
      listenable: sceneManager,
      builder: (context, widget) {
        final scene = sceneManager.currentScene;
        return ListenableBuilder(
          listenable: scene ?? sceneManager,
          builder: (context, child) => LayoutBuilder(
            builder: (context, constraints) {
              controller.setCanvasSize(constraints.biggest);
              return Stack(
                children: [
                  for (final layer in scene?.layers ?? []) _buildLayer(layer),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLayer(InfinityLayer layer) {
    return ListenableBuilder(
      listenable: layer,
      builder: (context, child) {
        if (!layer.isVisible) return const SizedBox.shrink();
        return Stack(
          children: [
            ...layer.objects,
            for (final subLayer in layer.subLayer) _buildLayer(subLayer),
          ],
        );
      },
    );
  }
}
