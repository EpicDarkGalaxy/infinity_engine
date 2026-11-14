import 'package:flutter/material.dart' as flutter;
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/render/canvas_widget.dart';
import 'package:infinity_engine/infinity_engine/components/render/collider_debug_painter.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_input/input_listener.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_tick.dart';
import 'package:infinity_engine/infinity_engine/infinity_container.dart';

part 'singularity_part.dart';

class InfinityEngine {
  static final InfinityEngine _instance = InfinityEngine._internal();
  factory InfinityEngine() => _instance;
  InfinityEngine._internal();

  double fps = 60;
  bool debugMode = false;

  // Predefined layers for the engine, can be modified by the user
  // Higher zIndex means the layer will be rendered on top of lower zIndex layers
  List<InfinityLayer> get layers => InfinityLayer.layers;

  late final CanvasController _canvasController;
  late final CanvasWidget _canvasWidget;

  final List<void Function()> _startCallbacks = [];

  final InfinityContainer _container = InfinityContainer();
  List<InfinityObject> get objects => _container.objects;

  bool isRunning = false;

  void init() {
    _canvasController = CanvasController();

    _canvasWidget = CanvasWidget(controller: _canvasController);
    flutter.debugPrint("InfinityEngine Initialized");
  }

  static void addStartCallback(void Function() callback) {
    _instance._startCallbacks.add(callback);
  }

  /// Called every frame by the InfinityTick
  void _loop(double deltaTime) {
    if (!isRunning) return;

    if (_startCallbacks.isNotEmpty) {
      for (var callback in List.unmodifiable(_startCallbacks)) {
        callback();
      }
      _startCallbacks.clear();
    }

    // Run individual update callbacks (scripts)
    final List<InfinityLoop> loops = _container.loops;
    if (loops.isEmpty) {
      flutter.debugPrint("No loops to update");
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
    engine._canvasController.addObject(object.layer.zIndex, object);

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

    flutter.debugPrint('Added object "${object.state.name}"');
  }

  static void removeObject(InfinityObject object) {
    final engine = InfinityEngine();
    if (!engine._container.removeObject(object)) return;
    InfinityLayer.removeObject(object);
    engine._canvasController.removeObject(object.layer.zIndex, object);
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
      engine._canvasController.removeObject(currentLayer.zIndex, object);
      engine._canvasController.addObject(targetLayer.zIndex, object);
    } else {
      object.state.layer = targetLayer;
    }
  }

  void startEngine() {
    isRunning = true;
    // for (var call in _startCallbacks) {
    //   call.call();
    // }
  }
}
