import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:infinity_engine/components.dart';
import 'package:infinity_engine/src/components/infinity_log.dart';
import 'package:infinity_engine/src/components/render/canvas_widget.dart';
import 'package:infinity_engine/src/components/render/collider_debug_painter.dart';
import 'package:infinity_engine/src/components/infinity_input/input_listener.dart';
import 'package:infinity_engine/src/components/infinity_tick.dart';
import 'package:infinity_engine/src/infinity_container.dart';

export 'singularity.dart' show Singularity, SingularityLoop, runApp;

part 'singularity_part.dart';

class InfinityEngine {
  static final InfinityEngine _instance = InfinityEngine._internal();
  factory InfinityEngine() => _instance;
  InfinityEngine._internal();

  double fps = 60;
  bool debugMode = false;

  bool get suppressInfoLogs => InfinityLog.suppressInfoLogs;
  set suppressInfoLogs(bool value) => InfinityLog.suppressInfoLogs = value;

  bool get suppressDebugLogs => InfinityLog.suppressDebugLogs;
  set suppressDebugLogs(bool value) => InfinityLog.suppressDebugLogs = value;

  bool get suppressWarningLogs => InfinityLog.suppressWarningLogs;
  set suppressWarningLogs(bool value) =>
      InfinityLog.suppressWarningLogs = value;

  bool get suppressErrorLogs => InfinityLog.suppressErrorLogs;
  set suppressErrorLogs(bool value) => InfinityLog.suppressErrorLogs = value;

  late final CanvasController _canvasController;
  late final CanvasWidget _canvasWidget;

  @internal
  CanvasWidget get canvasWidget => _canvasWidget;

  final List<void Function()> _startCallbacks = [];

  final InfinitySceneManager _sceneManager = InfinitySceneManager();
  InfinitySceneManager get sceneManager => _sceneManager;

  final InfinityContainer _container = InfinityContainer();
  List<InfinityObject> get objects => _container.objects;

  bool isRunning = false;
  bool isPaused = false;

  /// Prevents the engine from updating the game state
  void pause() => isPaused = true;

  /// Resumes the engine to update the game state
  void resume() => isPaused = false;

  void init() {
    _canvasController = CanvasController();

    _canvasWidget = CanvasWidget(controller: _canvasController);
    InfinityLog.i("InfinityEngine Initialized");
  }

  @internal
  static void addStartCallback(void Function() callback) {
    _instance._startCallbacks.add(callback);
  }

  /// Called every frame by the InfinityTick
  void _loop(double deltaTime) {
    if (!isRunning || isPaused) return;

    if (_startCallbacks.isNotEmpty) {
      for (var callback in List.unmodifiable(_startCallbacks)) {
        callback();
      }
      _startCallbacks.clear();
    }

    // Run individual update callbacks (scripts)
    final List<InfinityLoop> globalScopedLoops = _container.loops;
    final currentScene = sceneManager.currentScene;
    final List<InfinityLoop> sceneScopedLoops =
        currentScene?.container.loops ?? [];
    if (globalScopedLoops.isEmpty &&
        sceneScopedLoops.isEmpty &&
        currentScene is! InfinityLoop) {
      InfinityLog.i("No loops to update");
    }

    for (var loop in globalScopedLoops) {
      loop.update(deltaTime);
    }

    if (currentScene is InfinityLoop) {
      (currentScene as InfinityLoop).update(deltaTime);
    }
    for (var loop in sceneScopedLoops) {
      loop.update(deltaTime);
    }

    // Apply components
    _applyComponents(deltaTime);
  }

  /// Apply all component's effect to all objects
  void _applyComponents(double deltaTime) {
    final objects = [
      ..._container.objects,
      ...?_sceneManager.currentScene?.container.objects,
    ];
    for (int i = 0; i < objects.length; i++) {
      var object = objects[i];
      for (var component in object.components) {
        // Start from i + 1 to avoid checking pairs twice and skipping self
        component.apply(deltaTime);
        for (int j = i + 1; j < objects.length; j++) {
          var other = objects[j];
          component.collideWith(other);
        }
      }
    }
  }

  /// Update the active scene's state
  @internal
  void updateScene() {
    final sceneObjects = _sceneManager.currentScene?.container.objects ?? [];
    for (var object in sceneObjects) {
      object.refresh();
    }
  }

  static Vector2 get screenSize => _instance._canvasController.getCanvasSize();

  @internal
  void handleStartCallback(InfinityObject object) {
    final engine = InfinityEngine();
    if (object is InfinityLoop) {
      final loop = object as InfinityLoop;
      if (engine.isRunning) {
        loop.start();
      } else {
        engine._startCallbacks.add(loop.start);
      }
    }

    for (InfinityLoop loop in object.loops) {
      if (engine.isRunning) {
        loop.start();
      } else {
        engine._startCallbacks.add(loop.start);
      }
    }
  }

  /// Add an object to the engine
  /// ## Parameters
  /// - [object] The object to add
  /// - [addToScene] Whether to add the object to the current scene, if false
  ///   the object will be added to the engine's lifecycle
  static void addObject(InfinityObject object, {bool addToScene = true}) {
    if (addToScene) {
      _addObjectToScene(object);
      return;
    }

    _addObjectToEngine(object);
    InfinityEngine().handleStartCallback(object);
    InfinityLog.i('Added object "${object.state.name}"');
  }

  static void _addObjectToEngine(InfinityObject object) {
    final engine = InfinityEngine();
    if (!engine._container.addObject(object)) return;
  }

  static void _addObjectToScene(InfinityObject object) {
    final scene = _instance.sceneManager.currentScene;
    if (scene == null) return;
    scene.addObject(object);
  }

  static void _removeObjectFromEngine(InfinityObject object) {
    final engine = InfinityEngine();
    if (!engine._container.removeObject(object)) return;
  }

  static void _removeObjectFromScene(InfinityObject object) {
    final scene = _instance.sceneManager.currentScene;
    if (scene == null) return;
    scene.removeObject(object);
  }

  /// Removes an object from the scene.
  /// ## Parameters:
  /// - `object`: The object to remove.
  /// - `fromScene`: If provided, selects whether to remove from the scene or
  ///   engine container. Otherwise, the object's current owner is detected.
  static void removeObject(InfinityObject object, {bool? fromScene}) {
    final currentScene = _instance.sceneManager.currentScene;
    final shouldRemoveFromScene =
        fromScene ?? (currentScene?.container.containsObject(object) ?? false);

    if (shouldRemoveFromScene) {
      _removeObjectFromScene(object);
    } else {
      _removeObjectFromEngine(object);
    }
    InfinityLog.d('Object removed: ${object.name}');
  }

  static InfinityObject? getObjectByName(String name) {
    final object =
        InfinityEngine()._container.getObjectByName(name) ??
        _instance.sceneManager.currentScene?.container.getObjectByName(name);
    if (object == null) {
      InfinityLog.e('Object with name "$name" not found');
      return null;
    }
    return object;
  }

  static T? getObject<T extends InfinityObject>() {
    final object =
        InfinityEngine()._container.getObjectByType<T>() ??
        _instance.sceneManager.currentScene?.container.getObjectByType<T>();
    if (object == null) {
      InfinityLog.e('Object with name "$T" not found');
      return null;
    }
    return object;
  }

  /// Adds a layer to the current scene.
  static void addLayer(InfinityLayer layer) {
    final scene = _instance.sceneManager.currentScene;
    if (scene == null) return;
    scene.addLayer(layer);
  }

  /// Removes a layer from the current scene.
  static void removeLayer(InfinityLayer layer) {
    final scene = _instance.sceneManager.currentScene;
    if (scene == null) return;
    scene.removeLayer(layer);
  }

  static InfinityLayer? getLayerByName(String name) {
    final scene = _instance.sceneManager.currentScene;
    if (scene == null) return null;
    return scene.getLayerByName(name);
  }

  // static void setObjectLayer(InfinityObject object, InfinityLayer newLayer) {
  //   final engine = InfinityEngine();
  //   final targetLayer = InfinityLayer.getLayerByName(newLayer.name);
  //   if (targetLayer == null) {
  //     throw StateError("Layer ${newLayer.name} does not exist.");
  //   }

  //   final currentLayer = object.layer;
  //   if (identical(currentLayer, targetLayer)) return;

  //   if (engine._container.containsObject(object)) {
  //     InfinityLayer.moveObject(object, targetLayer);
  //   } else {
  //     object.state.layer = targetLayer;
  //   }
  // }

  bool isObjectInViewport(InfinityObject object) {
    final screenSize = _canvasController.getCanvasSize().toSize;
    final objPos = object.position;
    final objSize = object.size.toSize;
    final bool withinX =
        objPos.x + objSize.width >= 0 && objPos.x <= screenSize.width;
    final bool withinY =
        objPos.y + objSize.height >= 0 && objPos.y <= screenSize.height;
    return withinX && withinY;
  }

  @internal
  void startEngine() {
    if (isRunning) return;

    isRunning = true;

    if (_startCallbacks.isNotEmpty) {
      for (var callback in List.unmodifiable(_startCallbacks)) {
        callback();
      }
      _startCallbacks.clear();
    }
  }
}
