import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/src/components.dart';
import 'package:infinity_engine/src/components/render/canvas_widget.dart';
import 'package:infinity_engine/src/infinity_engine.dart';

void main() {
  testWidgets('renders the scene canvas with debug mode disabled', (
    tester,
  ) async {
    final engine = InfinityEngine();
    engine.init();
    engine.debugMode = false;

    final object = InfinityObject(
      key: const ValueKey('scene-object'),
      state: InfinityObjectState(size: const Vector2(32, 32)),
    );
    InfinityEngine.addObject(object);

    await tester.pumpWidget(Singularity(defaultScene: SingularityLoop()));

    expect(tester.getSize(find.byType(CanvasWidget)), isNot(Size.zero));
    expect(find.byKey(const ValueKey('scene-object')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    InfinityEngine.removeObject(object);
  });

  group('CanvasController', () {
    test('auto-assigns indices and rejects duplicate sibling indices', () {
      final explicitLayer = InfinityLayer.createLayer(
        name: 'Canvas Explicit Index Layer',
        zIndex: -20,
      );
      final automaticLayer = InfinityLayer.createLayer(
        name: 'Canvas Automatic Index Layer',
      );
      final parentLayer = InfinityLayer.createLayer(
        name: 'Canvas Index Parent Layer',
        zIndex: -19,
      );
      final explicitSubLayer = InfinityLayer.createSubLayer(
        parent: parentLayer,
        name: 'Canvas Explicit Sublayer',
        zIndex: -20,
      );
      final automaticSubLayer = InfinityLayer.createSubLayer(
        parent: parentLayer,
        name: 'Canvas Automatic Sublayer',
      );
      addTearDown(() {
        InfinityLayer.removeSubLayer(parentLayer, explicitSubLayer);
        InfinityLayer.removeSubLayer(parentLayer, automaticSubLayer);
        InfinityLayer.removeLayer(explicitLayer);
        InfinityLayer.removeLayer(automaticLayer);
        InfinityLayer.removeLayer(parentLayer);
      });

      expect(
        automaticLayer.zIndex,
        InfinityLayer.layers
                .where((layer) => !identical(layer, automaticLayer))
                .map((layer) => layer.zIndex)
                .reduce((first, second) => first > second ? first : second) +
            1,
      );
      expect(automaticSubLayer.zIndex, explicitSubLayer.zIndex + 1);
      expect(InfinityLayer.getLayerByZIndex(-20), same(explicitLayer));
      expect(
        InfinityLayer.getLayerByZIndex(-20, parent: parentLayer),
        same(explicitSubLayer),
      );
      expect(
        () => InfinityLayer.createLayer(
          name: 'Canvas Duplicate Index Layer',
          zIndex: explicitLayer.zIndex,
        ),
        throwsStateError,
      );
      expect(
        () => InfinityLayer.createSubLayer(
          parent: parentLayer,
          name: 'Canvas Duplicate Sublayer Index',
          zIndex: explicitSubLayer.zIndex,
        ),
        throwsStateError,
      );
    });

    test('registers objects assigned to sublayers', () {
      final controller = CanvasController();
      final parentLayer = InfinityLayer(
        name: 'Canvas Sublayer Parent',
        zIndex: -8,
      );
      final subLayer = InfinityLayer(name: 'Canvas Sublayer Child', zIndex: 1);
      InfinityLayer.addLayer(parentLayer);
      InfinityLayer.addSubLayer(parentLayer, subLayer);

      final parentObject = InfinityObject(
        state: InfinityObjectState(layer: parentLayer),
      );
      final subLayerObject = InfinityObject(
        state: InfinityObjectState(layer: subLayer),
      );
      InfinityLayer.addObject(parentObject);
      InfinityLayer.addObject(subLayerObject);

      addTearDown(() {
        controller.dispose();
        InfinityLayer.removeObject(parentObject);
        InfinityLayer.removeObject(subLayerObject);
        InfinityLayer.removeSubLayer(parentLayer, subLayer);
        InfinityLayer.removeLayer(parentLayer);
      });

      expect(InfinityLayer.getLayerByObject(subLayerObject), same(subLayer));
      expect(
        controller.objects.where(
          (object) =>
              identical(object, parentObject) ||
              identical(object, subLayerObject),
        ),
        [parentObject, subLayerObject],
      );
    });

    test('orders layers by z-index and objects by insertion order', () {
      final controller = CanvasController();
      final lowerLayer = InfinityLayer(
        name: 'Canvas Order Lower Layer',
        zIndex: -10,
      );
      final upperLayer = InfinityLayer(
        name: 'Canvas Order Upper Layer',
        zIndex: -9,
      );
      InfinityLayer.addLayer(upperLayer);
      InfinityLayer.addLayer(lowerLayer);

      final lowerFirst = InfinityObject(
        state: InfinityObjectState(layer: lowerLayer),
      );
      final lowerSecond = InfinityObject(
        state: InfinityObjectState(layer: lowerLayer),
      );
      final upperObject = InfinityObject(
        state: InfinityObjectState(layer: upperLayer),
      );
      final testObjects = [lowerFirst, lowerSecond, upperObject];

      InfinityLayer.addObject(lowerFirst);
      InfinityLayer.addObject(lowerSecond);
      InfinityLayer.addObject(upperObject);

      addTearDown(() {
        controller.dispose();
        for (final object in testObjects) {
          InfinityLayer.removeObject(object);
        }
        InfinityLayer.removeLayer(lowerLayer);
        InfinityLayer.removeLayer(upperLayer);
      });

      final actualTestObjects = controller.objects
          .where((object) => testObjects.contains(object))
          .toList();

      expect(actualTestObjects, [lowerFirst, lowerSecond, upperObject]);
    });
  });

  testWidgets('reports the canvas logical size from its layout constraints', (
    tester,
  ) async {
    final controller = CanvasController();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 320,
            height: 240,
            child: CanvasWidget(controller: controller),
          ),
        ),
      ),
    );

    final canvasSize = controller.getCanvasSize();
    expect(canvasSize.x, 320);
    expect(canvasSize.y, 240);
  });

  group('CanvasController layer changes', () {
    test('stops returning objects after they are removed from a layer', () {
      final controller = CanvasController();
      final layer = InfinityLayer(name: 'Canvas Removal Test Layer', zIndex: 2);
      InfinityLayer.addLayer(layer);
      final object = InfinityObject(state: InfinityObjectState(layer: layer));
      InfinityLayer.addObject(object);
      addTearDown(() {
        controller.dispose();
        InfinityLayer.removeObject(object);
        InfinityLayer.removeLayer(layer);
      });

      expect(controller.objects, contains(object));

      InfinityLayer.removeObject(object);

      expect(controller.objects, isNot(contains(object)));
    });
  });
}
