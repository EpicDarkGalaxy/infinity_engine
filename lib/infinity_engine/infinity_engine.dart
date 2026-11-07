import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity/components/canvas_widget.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';

import 'package:hit_them/infinity_engine/infinity/infinity_object.dart';

class InfinityEngine {
  static final InfinityEngine _instance = InfinityEngine._internal();
  factory InfinityEngine() => _instance;
  InfinityEngine._internal();

  double fps = 15;
  // late final DeltaTimeWidget gameTick;

  /// The canvas to draw on
  Widget get canvas => _canvas;
  late final CanvasWidget _canvas;

  List<InfinityObject> objects = [];

  List<VoidCallback> startCallbacks = [];
  List<void Function(double)> updateCallbacks = [];

  final bool state = true;

  void init() {
    _canvas = CanvasWidget(objects: objects);
    print("gameTick");
  }

  void loop(double time) {
    debugPrint("Loop");

    if (state == false) return;
    for (InfinityObject object in objects) {
      debugPrint("Updating object");
      object.position = Offset(3, 3);
    }
    // Run update callbacks
    debugPrint("Running update callbacks");
    for (void Function(double) call in updateCallbacks) {
      call.call(time);
    }
  }

  void addObject(InfinityObject object) {
    objects.add(object);
    _canvas.addObject(object);
    _addCallbacks(object);
  }

  void _addCallbacks(InfinityObject object) {
    if (object.loops == null) return;
    debugPrint("Adding callbacks");
    for (InfinityLoop loop in object.loops!) {
      startCallbacks.add(loop.start);
    }
    for (InfinityLoop loop in object.loops!) {
      updateCallbacks.add(loop.update);
    }
  }

  void runEngine(Widget app) {
    runApp(app);

    // Run start callbacks
    for (VoidCallback call in startCallbacks) {
      call.call();
    }
  }
}
