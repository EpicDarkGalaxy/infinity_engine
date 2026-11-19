import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/components.dart';
import 'package:infinity_engine/src/components/render/canvas_widget.dart';
import 'package:infinity_engine/engine.dart';

void main() {
  testWidgets('canvas rebuilds when a scene layer is added or removed', (
    tester,
  ) async {
    final sceneManager = InfinitySceneManager();
    final scene = InfinityScene(name: 'Layer notification test scene');
    sceneManager.addScene(scene);
    sceneManager.switchTo(scene);

    final controller = CanvasController();
    final layer = InfinityLayer(name: 'Canvas notification layer', zIndex: 1);
    final object = InfinityObject(
      key: const ValueKey('canvas-layer-object'),
      state: InfinityObjectState(layer: layer),
    );

    await tester.pumpWidget(
      MaterialApp(home: CanvasWidget(controller: controller)),
    );
    expect(find.byKey(const ValueKey('canvas-layer-object')), findsNothing);

    scene.addLayer(layer);
    scene.addObject(object);
    await tester.pump();
    expect(find.byKey(const ValueKey('canvas-layer-object')), findsOneWidget);

    InfinityEngine.removeObject(object);
    await tester.pump();
    expect(find.byKey(const ValueKey('canvas-layer-object')), findsNothing);
    expect(scene.container.containsObject(object), isFalse);

    scene.addObject(object);
    await tester.pump();
    expect(find.byKey(const ValueKey('canvas-layer-object')), findsOneWidget);

    final subLayer = InfinityLayer(
      name: 'Canvas notification sublayer',
      zIndex: 1,
    );
    layer.addSubLayer(subLayer);
    final subLayerObject = InfinityObject(
      key: const ValueKey('canvas-sublayer-object'),
      state: InfinityObjectState(layer: subLayer),
    );
    scene.addObject(subLayerObject);
    await tester.pump();
    expect(
      find.byKey(const ValueKey('canvas-sublayer-object')),
      findsOneWidget,
    );

    subLayer.isVisible = false;
    await tester.pump();
    expect(find.byKey(const ValueKey('canvas-sublayer-object')), findsNothing);
    subLayer.isVisible = true;
    await tester.pump();

    layer.removeSubLayer(layer, subLayer);
    await tester.pump();
    expect(find.byKey(const ValueKey('canvas-sublayer-object')), findsNothing);

    scene.removeLayer(layer);
    await tester.pump();
    expect(find.byKey(const ValueKey('canvas-layer-object')), findsNothing);

    expect(
      () => scene.layers.add(InfinityLayer(name: 'Untracked layer', zIndex: 2)),
      throwsUnsupportedError,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    sceneManager.removeScene(scene);
  });

  testWidgets(
    'switching scenes preserves their independent layers and objects',
    (tester) async {
      InfinityEngine().startEngine();
      final sceneManager = InfinitySceneManager();
      final firstScene = InfinityScene(name: 'First switch scene');
      final secondScene = InfinityScene(name: 'Second switch scene');
      sceneManager.addScene(firstScene);
      sceneManager.addScene(secondScene);

      final firstObject = InfinityObject(
        key: const ValueKey('first-scene-object'),
        state: InfinityObjectState(),
      );
      final secondObject = InfinityObject(
        key: const ValueKey('second-scene-object'),
        state: InfinityObjectState(),
        loops: [_CountingStartLoop()],
      );
      final secondObjectLoop = secondObject.loops.single as _CountingStartLoop;
      firstScene.addObject(firstObject);
      secondScene.addObject(secondObject);
      expect(secondObjectLoop.startCount, 0);
      expect(firstScene.layers, isNot(same(secondScene.layers)));
      expect(firstObject.layer, same(firstScene.layers.first));
      expect(secondObject.layer, same(secondScene.layers.first));

      sceneManager.switchTo(firstScene);
      final controller = CanvasController();
      await tester.pumpWidget(
        MaterialApp(home: CanvasWidget(controller: controller)),
      );
      expect(find.byKey(const ValueKey('first-scene-object')), findsOneWidget);
      expect(find.byKey(const ValueKey('second-scene-object')), findsNothing);

      sceneManager.switchTo(secondScene, keepPreviousAlive: true);
      await tester.pump();
      expect(find.byKey(const ValueKey('first-scene-object')), findsNothing);
      expect(find.byKey(const ValueKey('second-scene-object')), findsOneWidget);
      expect(secondObjectLoop.startCount, 1);

      sceneManager.switchTo(firstScene, keepPreviousAlive: true);
      await tester.pump();
      expect(find.byKey(const ValueKey('first-scene-object')), findsOneWidget);
      expect(find.byKey(const ValueKey('second-scene-object')), findsNothing);
      expect(firstScene.layers, hasLength(2));
      expect(firstScene.layers.first.isVisible, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      sceneManager.switchTo(secondScene);
      sceneManager.removeScene(firstScene);
      sceneManager.removeScene(secondScene);
    },
  );

  testWidgets('switchTo can keep or purge the previous scene', (tester) async {
    final sceneManager = InfinitySceneManager();
    final firstScene = InfinityScene(name: 'Keep or purge first scene');
    final secondScene = InfinityScene(name: 'Keep or purge second scene');
    sceneManager.addScene(firstScene);
    sceneManager.addScene(secondScene);

    final object = InfinityObject(
      key: const ValueKey('keep-or-purge-object'),
      state: InfinityObjectState(),
    );
    firstScene.addObject(object);
    final originalLayer = firstScene.layers.first;

    sceneManager.switchTo(firstScene);
    await tester.pumpWidget(
      MaterialApp(home: CanvasWidget(controller: CanvasController())),
    );
    expect(find.byKey(const ValueKey('keep-or-purge-object')), findsOneWidget);

    sceneManager.switchTo(secondScene, keepPreviousAlive: true);
    await tester.pump();
    expect(firstScene.container.containsObject(object), isTrue);
    expect(firstScene.layers.first, same(originalLayer));

    sceneManager.switchTo(firstScene, keepPreviousAlive: true);
    await tester.pump();
    expect(find.byKey(const ValueKey('keep-or-purge-object')), findsOneWidget);

    sceneManager.switchTo(secondScene);
    await tester.pump();
    expect(firstScene.container.containsObject(object), isFalse);
    expect(originalLayer.objects, isEmpty);
    expect(firstScene.layers, hasLength(2));
    expect(firstScene.layers.first, isNot(same(originalLayer)));

    sceneManager.switchTo(firstScene);
    await tester.pump();
    expect(find.byKey(const ValueKey('keep-or-purge-object')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    sceneManager.removeScene(firstScene);
    sceneManager.removeScene(secondScene);
  });

  test('purged scenes rerun setup while preserved scenes resume', () {
    InfinityEngine().startEngine();
    final sceneManager = InfinitySceneManager();
    final menuScene = _SceneSetupScene();
    final gameScene = InfinityScene(name: 'Lifecycle game scene');
    sceneManager.addScene(menuScene);
    sceneManager.addScene(gameScene);

    sceneManager.switchTo(menuScene);
    expect(menuScene.loadCount, 1);
    expect(menuScene.container.objects, hasLength(1));
    expect(menuScene.layers.where((layer) => layer.name == 'Background'), [
      menuScene.backgroundLayer,
    ]);

    sceneManager.switchTo(gameScene, keepPreviousAlive: true);
    final inactiveObject = InfinityObject(
      state: InfinityObjectState(name: 'Inactive scene object'),
      loops: [_CountingStartLoop()],
    );
    final inactiveObjectLoop =
        inactiveObject.loops.single as _CountingStartLoop;
    menuScene.addObject(inactiveObject);
    expect(inactiveObjectLoop.startCount, 0);

    sceneManager.switchTo(menuScene, keepPreviousAlive: true);
    expect(menuScene.loadCount, 1);
    expect(inactiveObjectLoop.startCount, 1);
    expect(menuScene.container.containsObject(inactiveObject), isTrue);

    sceneManager.switchTo(gameScene);
    expect(menuScene.unloadCount, 2);
    expect(menuScene.container.objects, isEmpty);
    expect(menuScene.getLayerByName('Background'), isNull);
    expect(menuScene.layers, hasLength(2));

    sceneManager.switchTo(menuScene);
    expect(menuScene.loadCount, 2);
    expect(menuScene.container.objects, hasLength(1));
    expect(menuScene.layers.where((layer) => layer.name == 'Background'), [
      menuScene.backgroundLayer,
    ]);

    sceneManager.switchTo(gameScene, keepPreviousAlive: true);
    sceneManager.switchTo(menuScene, keepPreviousAlive: true);
    expect(menuScene.loadCount, 2);
    expect(menuScene.container.objects, hasLength(1));
    expect(menuScene.layers.where((layer) => layer.name == 'Background'), [
      menuScene.backgroundLayer,
    ]);

    sceneManager.removeScene(menuScene);
    sceneManager.removeScene(gameScene);
  });

  testWidgets('inactive scene edits do not rebuild the active scene', (
    tester,
  ) async {
    final sceneManager = InfinitySceneManager();
    final activeScene = InfinityScene(name: 'Active isolation scene');
    final inactiveScene = InfinityScene(name: 'Inactive isolation scene');
    sceneManager.addScene(activeScene);
    sceneManager.addScene(inactiveScene);
    sceneManager.switchTo(activeScene);

    var activeBuildCount = 0;
    final activeObject = _BuildCountingObject(
      key: const ValueKey('active-isolation-object'),
      state: InfinityObjectState(),
      onBuild: () => activeBuildCount++,
    );
    activeScene.addObject(activeObject);

    await tester.pumpWidget(
      MaterialApp(home: CanvasWidget(controller: CanvasController())),
    );
    expect(activeBuildCount, greaterThan(0));
    final activeBuildCountBeforeInactiveEdits = activeBuildCount;

    inactiveScene.addLayer(
      InfinityLayer(name: 'Inactive custom layer', zIndex: 1),
    );
    inactiveScene.addObject(InfinityObject(state: InfinityObjectState()));
    inactiveScene.layers.first.isVisible = false;
    await tester.pump();

    expect(activeBuildCount, activeBuildCountBeforeInactiveEdits);
    expect(
      find.byKey(const ValueKey('active-isolation-object')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    sceneManager.removeScene(activeScene);
    sceneManager.removeScene(inactiveScene);
  });

  test('cannot switch to a scene that is not registered', () {
    expect(
      () =>
          InfinitySceneManager().switchTo(InfinityScene(name: 'Unregistered')),
      throwsStateError,
    );
  });

  testWidgets('only the active scene loop updates', (tester) async {
    final engine = InfinityEngine();
    engine.init();
    final sceneManager = InfinitySceneManager();
    final firstScene = _CountingScene();
    final secondScene = _CountingScene();
    sceneManager.addScene(firstScene);
    sceneManager.addScene(secondScene);
    sceneManager.switchTo(firstScene);
    engine.startEngine();

    await tester.pumpWidget(Singularity(defaultScene: firstScene));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(firstScene.updateCount, greaterThan(0));
    expect(secondScene.updateCount, 0);

    sceneManager.switchTo(secondScene);
    final firstSceneUpdatesAtSwitch = firstScene.updateCount;
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(firstScene.updateCount, firstSceneUpdatesAtSwitch);
    expect(secondScene.updateCount, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    sceneManager.removeScene(firstScene);
    sceneManager.removeScene(secondScene);
  });
}

class _CountingScene extends SingularityLoop {
  int updateCount = 0;

  @override
  void update(double dt) {
    updateCount++;
  }
}

class _SceneSetupScene extends InfinityScene {
  _SceneSetupScene() : super(name: 'Lifecycle menu scene');

  int loadCount = 0;
  int unloadCount = 0;
  InfinityLayer? backgroundLayer;

  @override
  void onLoad() {
    loadCount++;
    final layer = InfinityLayer(name: 'Background', zIndex: -1);
    backgroundLayer = layer;
    addLayer(layer);
    addObject(
      InfinityObject(
        state: InfinityObjectState(name: 'Background', layer: layer),
      ),
    );
  }

  @override
  void onUnload() {
    unloadCount++;
  }
}

class _CountingStartLoop with InfinityLoop {
  int startCount = 0;

  @override
  void start() {
    startCount++;
  }

  @override
  void update(double dt) {}
}

class _BuildCountingObject extends InfinityObject {
  _BuildCountingObject({
    super.key,
    required super.state,
    required this.onBuild,
  });

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return super.build(context);
  }
}
