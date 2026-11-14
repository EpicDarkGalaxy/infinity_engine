import 'package:infinity_engine/infinity_engine/components/infinity_loop.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

/// Owns the objects and loops currently registered with the engine.
class InfinityContainer {
  final List<InfinityObject> _objects = [];

  List<InfinityObject> get objects => List.unmodifiable(_objects);
  List<InfinityLoop> get loops {
    List<InfinityLoop> loops = [];
    for (InfinityObject obj in _objects) {
      if (obj is InfinityLoop) {
        loops.add(obj as InfinityLoop);
      }
      loops.addAll(obj.loops);
    }
    return loops;
  }

  bool containsObject(InfinityObject object) => _objects.contains(object);

  bool addObject(InfinityObject object) {
    if (containsObject(object)) return false;
    _objects.add(object);
    return true;
  }

  InfinityObject? getObjectByName(String name) {
    for (InfinityObject obj in _objects) {
      if (obj.name == name) {
        return obj;
      }
    }
    return null;
  }

  /// Removes the object from the container.
  ///
  /// Returns true if the object was removed, false otherwise.
  /// (This is the same as the return value of [List.remove])
  bool removeObject(InfinityObject object) {
    return _objects.remove(object);
  }
}
