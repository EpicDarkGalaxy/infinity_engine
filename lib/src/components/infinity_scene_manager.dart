import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:infinity_engine/src/components/infinity_scene.dart';

class InfinitySceneManager extends ChangeNotifier {
  static final InfinitySceneManager _instance =
      InfinitySceneManager._internal();
  factory InfinitySceneManager() {
    return _instance;
  }
  InfinitySceneManager._internal();

  final List<InfinityScene> _scenes = [];
  InfinityScene? get currentScene =>
      _scenes.firstWhereOrNull((scene) => scene.isActive);

  void addScene(InfinityScene scene) {
    if (_scenes.contains(scene)) return;
    _scenes.add(scene);
  }

  void removeScene(InfinityScene scene) {
    if (!_scenes.contains(scene)) return;
    final wasActive = identical(currentScene, scene);
    if (wasActive) {
      scene.deactivate();
    }
    _scenes.remove(scene);
    if (wasActive) notifyListeners();
  }

  InfinityScene? getSceneByName(String name) {
    return _scenes.firstWhereOrNull((scene) => scene.name == name);
  }

  T? getScene<T extends InfinityScene>() {
    return _scenes.firstWhereOrNull((element) => element is T) as T?;
  }

  /// Switches to a registered scene.
  ///
  /// When [keepPreviousAlive] is false, the previous scene is unloaded and
  /// cleared but remains registered so it can be activated again. A preserved
  /// scene keeps its contents and resumes without calling [InfinityScene.onLoad]
  /// again.
  void switchTo(InfinityScene scene, {bool keepPreviousAlive = false}) {
    if (!_scenes.contains(scene)) {
      throw StateError('Scene "${scene.name}" has not been added.');
    }
    if (identical(currentScene, scene)) return;
    final previousScene = currentScene;
    previousScene?.deactivate();
    if (!keepPreviousAlive) {
      previousScene?.purge();
    }
    scene.activate();
    notifyListeners();
  }
}
