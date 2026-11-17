import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

/// Represents a layer in the Infinity Engine, which can be used to group objects and control their rendering order and visibility.
/// A layer can also have sub-layers to further organize objects.
/// ## Parameters
/// - [name] is the name of the layer.
/// - [zIndex] determines the rendering order of the layer. Higher zIndex layers are rendered on top of lower zIndex layers.
/// - [isVisible] determines if the layer is visible. If false, objects in this layer will not be rendered.
/// - [isCollidable] determines if objects in this layer can collide with objects in other layers. If false, collision checks will be
class InfinityLayer {
  final String name;
  final int zIndex;
  final List<InfinityLayer> _subLayers = [];
  bool isVisible;
  bool isCollidable;

  final List<InfinityObject> _objects = [];

  /// Gets the list of objects in this layer.
  List<InfinityObject> get objects => List.unmodifiable(_objects);

  /// Default Layer is used for rendering game objects.
  /// It is collidable and has a zIndex of 0 to ensure it is rendered below the UI layer.
  static final InfinityLayer defaultLayer = InfinityLayer(
    name: "Default Layer",
    zIndex: 0,
    isVisible: true,
    isCollidable: true,
  );

  /// UI Layer is used for rendering UI elements on top of the game.
  /// It is not collidable and has a high zIndex to ensure it is rendered on top of other layers.
  static final InfinityLayer uiLayer = InfinityLayer(
    name: "UI Layer",
    zIndex: 10000, // Ensure UI layer is rendered on top
    isVisible: true,
    isCollidable: false,
  );

  /// List of all layers in the engine.
  static final List<InfinityLayer> layers = [defaultLayer, uiLayer];

  /// Adds an object to the layer specified in the object's state.
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

  /// Moves an object to a new layer.
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

  /// Removes an object from its layer.
  static void removeObject(InfinityObject object) {
    final layer = getLayerByName(object.layer.name);
    if (layer != null) {
      layer._objects.remove(object);
    } else {
      throw Exception("Layer ${object.layer.name} does not exist.");
    }
  }

  // Helper to sort layers by zIndex.
  static void _sortLayers(List<InfinityLayer> layers) {
    layers.sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }

  /// Adds a layer to the engine.
  static void addLayer(InfinityLayer layer) {
    layers.add(layer);
    _sortLayers(layers);
  }

  /// Removes a layer from the engine.
  static void removeLayer(InfinityLayer layer) {
    layers.remove(layer);
  }

  static void addSubLayer(InfinityLayer layer, InfinityLayer subLayer) {
    layer._subLayers.add(subLayer);
    _sortLayers(layer._subLayers);
  }

  static void removeSubLayer(InfinityLayer layer, InfinityLayer subLayer) {
    layer._subLayers.remove(subLayer);
  }

  /// Gets a layer by its name.
  static InfinityLayer? getLayerByName(String name) {
    for (final layer in layers) {
      if (layer.name == name) return layer;
    }
    return null;
  }

  /// Gets a layer by its z-index.
  static InfinityLayer? getLayerByZIndex(int zIndex) {
    for (final layer in layers) {
      if (layer.zIndex == zIndex) return layer;
    }
    return null;
  }

  /// Gets a layer by its object.
  static InfinityLayer? getLayerByObject(InfinityObject object) {
    for (final layer in layers) {
      if (layer._objects.contains(object)) return layer;
    }
    return null;
  }

  /// Gets a list of layers by their visibility.
  static List<InfinityLayer> getLayersByVisibility(bool isVisible) {
    return layers.where((layer) => layer.isVisible == isVisible).toList();
  }

  /// Gets a list of layers by their collidability.
  static List<InfinityLayer> getLayersByCollidability(bool isCollidable) {
    return layers.where((layer) => layer.isCollidable == isCollidable).toList();
  }

  /// Represents a layer in the Infinity Engine, which can be used to group objects and control their rendering order and visibility.
  ///
  /// A layer can also have sub-layers to further organize objects.
  /// zIndex in sub-layers is relative to the parent layer.
  /// For example, a sub-layer with zIndex 1 will be rendered above a sub-layer with zIndex 0,
  /// but below the layers that have higher zIndex than the parent layer.
  ///
  /// ## Parameters
  /// - [name] is the name of the layer.
  /// - [zIndex] determines the rendering order of the layer. Higher zIndex layers are rendered on top of lower zIndex layers.
  /// - [isVisible] determines if the layer is visible. If false, objects in this layer will not be rendered.
  /// - [isCollidable] determines if objects in this layer can collide with objects in other layers. If false, collision checks will be
  InfinityLayer({
    required this.name,
    required this.zIndex,
    this.isVisible = true,
    this.isCollidable = false,
  });
}
