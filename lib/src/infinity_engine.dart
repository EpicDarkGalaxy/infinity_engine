import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:infinity_engine/src/components.dart';
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

  bool get suppressWarningLogs => InfinityLog.suppressWarningLogs;
  set suppressWarningLogs(bool value) =>
      InfinityLog.suppressWarningLogs = value;

  bool get suppressErrorLogs => InfinityLog.suppressErrorLogs;
  set suppressErrorLogs(bool value) => InfinityLog.suppressErrorLogs = value;

  late final CanvasController _canvasController;
  late final CanvasWidget _canvasWidget;

  final List<void Function()> _startCallbacks = [];

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
    final List<InfinityLoop> loops = _container.loops;
    if (loops.isEmpty) {
      InfinityLog.i("No loops to update");
    } else {
      for (var loop in loops) {
        loop.update(deltaTime);
      }
    }

    // Apply components
    _applyComponents(deltaTime);
  }

  /// Apply all component's effect to all objects
  void _applyComponents(double deltaTime) {
    final objects = _container.objects;
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

  static Vector2 get screenSize => _instance._canvasController.getCanvasSize();

  static void addObject(InfinityObject object) {
    final engine = InfinityEngine();
    if (!engine._container.addObject(object)) return;
    InfinityLayer.addObject(object);

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

    InfinityLog.i('Added object "${object.state.name}"');
  }

  static void removeObject(InfinityObject object) {
    final engine = InfinityEngine();
    if (!engine._container.removeObject(object)) return;
    InfinityLayer.removeObject(object);
  }

  static InfinityObject? getObjectByName(String name) {
    return InfinityEngine()._container.getObjectByName(name);
  }

  static void setObjectLayer(InfinityObject object, InfinityLayer newLayer) {
    final engine = InfinityEngine();
    final targetLayer = InfinityLayer.getLayerByName(newLayer.name);
    if (targetLayer == null) {
      throw StateError("Layer ${newLayer.name} does not exist.");
    }

    final currentLayer = object.layer;
    if (identical(currentLayer, targetLayer)) return;

    if (engine._container.containsObject(object)) {
      InfinityLayer.moveObject(object, targetLayer);
    } else {
      object.state.layer = targetLayer;
    }
  }

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
