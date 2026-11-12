import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

/// Owns the objects currently registered with the engine.
class InfinityContainer {
  final List<InfinityObject> _objects = [];

  List<InfinityObject> get objects => List.unmodifiable(_objects);

  bool containsObject(InfinityObject object) => _objects.contains(object);

  bool addObject(InfinityObject object) {
    if (_objects.contains(object)) return false;
    _objects.add(object);
    return true;
  }

  InfinityObject getObject(String name) {
    return _objects.firstWhere((element) => element.name == name);
  }

  /// Removes the object from the container.
  ///
  /// Returns true if the object was removed, false otherwise.
  /// (This is the same as the return value of [List.remove])
  bool removeObject(InfinityObject object) {
    return _objects.remove(object);
  }
}
