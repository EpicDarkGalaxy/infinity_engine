import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

/// Represents a layer in the Infinity Engine, which can be used to group objects and control their rendering order and visibility.
/// ## Parameters
/// - [name] is the name of the layer.
/// - [zIndex] determines the rendering order of the layer. Higher zIndex layers are rendered on top of lower zIndex layers.
/// - [isVisible] determines if the layer is visible. If false, objects in this layer will not be rendered.
/// - [isCollidable] determines if objects in this layer can collide with objects in other layers. If false, collision checks will be
class InfinityLayer {
  final String name;
  final int zIndex;
  final bool isVisible;
  final bool isCollidable;

  final List<InfinityObject> _objects = [];

  List<InfinityObject> get objects => List.unmodifiable(_objects);

  static final InfinityLayer defaultLayer = InfinityLayer(
    name: "Default Layer",
    zIndex: 0,
    isVisible: true,
    isCollidable: false,
  );

  static final InfinityLayer uiLayer = InfinityLayer(
    name: "UI Layer",
    zIndex: 1,
    isVisible: true,
    isCollidable: false,
  );

  static final List<InfinityLayer> layers = [defaultLayer, uiLayer];

  static void addObject(InfinityObject object) {
    final layer = getLayerByName(object.layer.name);
    if (layer != null) {
      if (!identical(layer, object.layer)) object.state.layer = layer;
      if (!layer._objects.contains(object)) {
        layer._objects.add(object);
      }
    } else {
      throw StateError("Layer ${object.layer.name} does not exist.");
    }
  }

  static void moveObject(InfinityObject object, InfinityLayer newLayer) {
    final targetLayer = getLayerByName(newLayer.name);
    if (targetLayer == null) {
      throw StateError("Layer ${newLayer.name} does not exist.");
    }

    final currentLayer = getLayerByObject(object);
    if (identical(currentLayer, targetLayer)) {
      return;
    }
    currentLayer?._objects.remove(object);
    if (!targetLayer._objects.contains(object)) {
      targetLayer._objects.add(object);
    }
    object.state.layer = targetLayer;
  }

  static void removeObject(InfinityObject object) {
    final layer = getLayerByName(object.layer.name);
    if (layer != null) {
      layer._objects.remove(object);
    } else {
      throw Exception("Layer ${object.layer.name} does not exist.");
    }
  }

  static void addLayer(InfinityLayer layer) {
    layers.add(layer);
    layers.sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }

  static void removeLayer(InfinityLayer layer) {
    layers.remove(layer);
  }

  static InfinityLayer? getLayerByName(String name) {
    for (final layer in layers) {
      if (layer.name == name) return layer;
    }
    return null;
  }

  static InfinityLayer? getLayerByZIndex(int zIndex) {
    for (final layer in layers) {
      if (layer.zIndex == zIndex) return layer;
    }
    return null;
  }

  static InfinityLayer? getLayerByObject(InfinityObject object) {
    for (final layer in layers) {
      if (layer._objects.contains(object)) return layer;
    }
    return null;
  }

  static List<InfinityLayer> getLayersByVisibility(bool isVisible) {
    return layers.where((layer) => layer.isVisible == isVisible).toList();
  }

  static List<InfinityLayer> getLayersByCollidability(bool isCollidable) {
    return layers.where((layer) => layer.isCollidable == isCollidable).toList();
  }

  InfinityLayer({
    required this.name,
    required this.zIndex,
    this.isVisible = true,
    this.isCollidable = false,
  });
}
