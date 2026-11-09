import 'package:flutter/material.dart' as flutter;
import 'package:infinity_engine/infinity_engine/components/render/canvas_widget.dart';
import 'package:infinity_engine/infinity_engine/components/render/collider_debug_painter.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_input/input_listener.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_loop.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/base_collider.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_tick.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_time.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_layer.dart';
import 'package:infinity_engine/infinity_engine/infinity_container.dart';

part 'singularity_part.dart';

class InfinityEngine {
  static final InfinityEngine _instance = InfinityEngine._internal();
  factory InfinityEngine() => _instance;
  InfinityEngine._internal();

  /// Does nothing
  InfinityEngine.init();

  double fps = 60;
  bool debugMode = false;

  // Predefined layers for the engine, can be modified by the user
  // Higher zIndex means the layer will be rendered on top of lower zIndex layers
  List<InfinityLayer> get layers => InfinityLayer.layers;

  late final CanvasController _canvasController;
  late final CanvasWidget _canvasWidget;

  final InfinityContainer container = InfinityContainer();
  List<InfinityObject> get objects => container.objects;

  final List<flutter.VoidCallback> _startCallbacks = [];
  final List<void Function(double)> _updateCallbacks = [];

  bool isRunning = false;

  void init() {
    _canvasController = CanvasController();

    _canvasWidget = CanvasWidget(controller: _canvasController);
    flutter.debugPrint("InfinityEngine Initialized");
  }

  /// Called every frame by the InfinityTick
  void _loop(double deltaTime) {
    if (!isRunning) return;

    // Apply components
    applyComponents(deltaTime);

    // Run individual update callbacks (scripts)
    for (var call in _updateCallbacks) {
      call(deltaTime);
    }
  }

  /// Apply all component's effect to all objects
  void applyComponents(double deltaTime) {
    final objects = container.objects;
    for (int i = 0; i < objects.length; i++) {
      var object = objects[i];
      for (var component in object.components) {
        component.apply(deltaTime);

        if (component is BaseCollider) {
          // Start from i + 1 to avoid checking pairs twice and skipping self
          for (int j = i + 1; j < objects.length; j++) {
            var other = objects[j];
            for (var otherComponent in other.components) {
              if (otherComponent is BaseCollider) {
                component.overlaps(otherComponent);
              }
            }
          }
        }
      }
    }
  }

  static void addObject(InfinityObject object) {
    final engine = InfinityEngine();
    if (!engine.container.addObject(object)) return;
    InfinityLayer.addObject(object);
    engine._canvasController.addObject(object.layer.zIndex, object);
    engine._addCallbacks(object);

    flutter.debugPrint('Added object "${object.state.name}"');

    // If engine is already running, run the new object's start callback immediately
    if (!engine.isRunning) {
      flutter.debugPrint('Engine is not running');
      return;
    }
    if (object.loops != null) {
      flutter.debugPrint('Calling Start for the object "${object.state.name}"');
      for (var loop in object.loops!) {
        loop.start();
      }
    } else {
      flutter.debugPrint('Object "${object.state.name}" has no loops');
    }
  }

  static void removeObject(InfinityObject object) {
    final engine = InfinityEngine();
    if (!engine.container.removeObject(object)) return;
    InfinityLayer.removeObject(object);
    engine._canvasController.removeObject(object.layer.zIndex, object);
  }

  static void setObjectLayer(InfinityObject object, InfinityLayer newLayer) {
    final engine = InfinityEngine();
    final targetLayer = InfinityLayer.getLayerByName(newLayer.name);
    if (targetLayer == null) {
      throw StateError("Layer ${newLayer.name} does not exist.");
    }

    final currentLayer = object.layer;
    if (identical(currentLayer, targetLayer)) return;

    if (engine.container.containsObject(object)) {
      InfinityLayer.moveObject(object, targetLayer);
      engine._canvasController.removeObject(currentLayer.zIndex, object);
      engine._canvasController.addObject(targetLayer.zIndex, object);
    } else {
      object.state.layer = targetLayer;
    }
  }

  void _addCallbacks(InfinityObject object) {
    if (object.loops == null) return;
    for (InfinityLoop loop in object.loops!) {
      if (!isRunning) {
        // If engine is running, don't start callbacks to the list
        _startCallbacks.add(loop.start);
      }
      _updateCallbacks.add(loop.update);
    }
  }

  void startEngine() {
    isRunning = true;
    for (var call in _startCallbacks) {
      call();
    }
  }
}
