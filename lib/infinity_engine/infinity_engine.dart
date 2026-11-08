import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/components/canvas_widget.dart';
import 'package:hit_them/infinity_engine/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';

class InfinityEngine {
  static final InfinityEngine _instance = InfinityEngine._internal();
  factory InfinityEngine() => _instance;
  InfinityEngine._internal();

  /// Does nothing
  InfinityEngine.init();

  double fps = 60;

  late final CanvasController _canvasController;
  late final CanvasWidget _canvasWidget;

  /// The canvas widget that renders the game
  Widget get canvas => _canvasWidget;

  final List<InfinityObject> _objects = [];
  List<InfinityObject> get objects => _objects;

  final List<VoidCallback> _startCallbacks = [];
  final List<void Function(double)> _updateCallbacks = [];

  bool isRunning = false;

  void init() {
    _canvasController = CanvasController();

    _canvasWidget = CanvasWidget(controller: _canvasController);
    debugPrint("InfinityEngine Initialized");
  }

  /// Called every frame by the InfinityTick
  void loop(double deltaTime) {
    if (!isRunning) return;

    // Apply components to the object
    for (var object in _objects) {
      for (var components in object.components) {
        components.apply(deltaTime);
      }
    }

    // 1. Run individual update callbacks (scripts)
    for (var call in _updateCallbacks) {
      call(deltaTime);
    }
  }

  void addObject(InfinityObject object) {
    _objects.add(object);
    _canvasController.addObject(object);
    _addCallbacks(object);

    debugPrint('Added object "${object.state.name}"');

    // If engine is already running, run the new object's start callback immediately
    if (!isRunning) {
      debugPrint('Engine is not running');
      return;
    }
    if (object.loops != null) {
      debugPrint('Calling Start for the object "${object.state.name}"');
      for (var loop in object.loops!) {
        loop.start();
      }
    } else {
      debugPrint('Object "${object.state.name}" has no loops');
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
