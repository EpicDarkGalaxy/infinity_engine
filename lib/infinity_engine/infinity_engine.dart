import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity/components/canvas_widget.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';

class InfinityEngine extends InfinityLoop {
  static final InfinityEngine _instance = InfinityEngine._internal();
  factory InfinityEngine() => _instance;
  InfinityEngine._internal();

  /// Does nothing
  InfinityEngine.init();

  double fps = 1;

  late final CanvasController _canvas;
  late final CanvasWidget _canvasWidget;

  /// The canvas widget that renders the game
  Widget get canvas => _canvasWidget;

  final List<InfinityObject> _objects = [];
  List<InfinityObject> get objects => _objects;

  final List<VoidCallback> _startCallbacks = [];
  final List<void Function(double)> _updateCallbacks = [];

  bool isRunning = true;

  void init() {
    _canvas = CanvasController();
    _canvasWidget = CanvasWidget(controller: _canvas);
    debugPrint("InfinityEngine Initialized");
  }

  /// Called every frame by InfinityTick before its own tick
  void loop(double deltaTime) {
    if (!isRunning) return;

    // 1. Run individual update callbacks (scripts)
    for (var call in _updateCallbacks) {
      call(deltaTime);
    }
  }

  void addObject(InfinityObject object) {
    _objects.add(object);
    _canvas.addObject(object);
    _addCallbacks(object);

    debugPrint('Added object "${object.state.name}"');

    // If engine is already running, run the new object's start callback immediately
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

  void runEngine(Widget app) {
    // Run start callbacks for all pre-registered objects
    for (VoidCallback call in _startCallbacks) {
      call();
      // remove the start callback after it's been called once
      _startCallbacks.remove(call);
    }

    runApp(app);
  }

  @override
  void update(double dt) {}

  @override
  void start() {}
}
