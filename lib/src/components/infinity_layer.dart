import 'package:flutter/foundation.dart';
import 'package:infinity_engine/infinity_engine.dart';
import 'package:infinity_engine/src/components/infinity_object.dart';

/// Represents a layer in the Infinity Engine, which can be used to group objects and control their rendering order and visibility.
/// A layer can also have sub-layers to further organize objects.
/// ## Parameters
/// - [name] is the name of the layer.
/// - [zIndex] determines the rendering order of the layer. Higher zIndex layers are rendered on top of lower zIndex layers.
/// - [isVisible] determines if the layer is visible. If false, objects in this layer will not be rendered.
/// - [isCollidable] determines if objects in this layer can collide with objects in other layers. If false, collision checks will be
class InfinityLayer extends ChangeNotifier {
  final String name;
  final int zIndex;
  final List<InfinityLayer> _subLayers = [];
  bool _isVisible;
  bool _isCollidable;

  // Sorted by zIndex, higher zIndex layers are rendered on top of lower zIndex layers
  final List<InfinityObject> _objects = [];

  /// Gets the list of objects in this layer.
  List<InfinityObject> get objects => List.unmodifiable(_objects);

  List<InfinityLayer> get subLayer => List.unmodifiable(_subLayers);

  bool get isVisible => _isVisible;
  set isVisible(bool value) {
    if (_isVisible == value) return;
    _isVisible = value;
    _notifySceneChanged();
  }

  bool get isCollidable => _isCollidable;
  set isCollidable(bool value) {
    if (_isCollidable == value) return;
    _isCollidable = value;
    _notifySceneChanged();
  }

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

  void _notifySceneChanged() {
    notifyListeners();
  }

  /// Adds an object to the layer specified in the object's state.
  @internal
  void addObject(InfinityObject object) {
    final layer = getLayerByName(object.layer.name);
    if (layer != null) {
      if (!identical(layer, object.layer)) object.state.layer = layer;
      if (!layer._objects.contains(object)) {
        layer._objects.add(object);
        layer._notifySceneChanged();
      }
    } else {
      throw StateError(
        "Layer ${object.layer.name} does not exist in the scene.",
      );
    }
  }

  /// Moves an object to a new layer.
  @internal
  void moveObject(InfinityObject object, InfinityLayer newLayer) {
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
    currentLayer?.notifyListeners();
    targetLayer.notifyListeners();
  }

  /// Removes an object from its layer.
  @internal
  void removeObject(InfinityObject object) {
    final layer = getLayerByObject(object) ?? getLayerByName(object.layer.name);
    if (layer == null) {
      throw StateError("Layer ${object.layer.name} does not exist.");
    }
    if (layer._objects.remove(object)) {
      _notifySceneChanged();
    }
  }

  // Helper to sort layers by zIndex.
  void _sortLayers(List<InfinityLayer> layers) {
    layers.sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }

  /// Adds a sublayer to this layer.
  void addSubLayer(InfinityLayer newSubLayer) {
    if (_subLayers.contains(newSubLayer)) return;
    if (_subLayers.any((existing) => existing.zIndex == newSubLayer.zIndex)) {
      throw StateError("A sublayer [] with z-index  already exists under .");
    }
    _subLayers.add(newSubLayer);
    _sortLayers(_subLayers);
    _notifySceneChanged();
  }

  int _nextZIndex(Iterable<InfinityLayer> siblings) {
    int? maxZIndex;
    for (final layer in siblings) {
      if (maxZIndex == null || layer.zIndex > maxZIndex) {
        maxZIndex = layer.zIndex;
      }
    }
    return maxZIndex == null ? 0 : maxZIndex + 1;
  }

  @internal
  void removeSubLayer(InfinityLayer layer, InfinityLayer subLayer) {
    if (layer._subLayers.remove(subLayer)) {
      _notifySceneChanged();
    }
  }

  Iterable<InfinityLayer> _layersAndSubLayers() sync* {
    yield this;
    for (final subLayer in _subLayers) {
      yield* subLayer._layersAndSubLayers();
    }
  }

  Iterable<InfinityLayer> _visibleSubLayers() sync* {
    if (!isVisible) return;
    yield this;
    for (final subLayer in _subLayers) {
      yield* subLayer._visibleSubLayers();
    }
  }

  Iterable<InfinityLayer> get visibleLayers sync* {
    for (final layer in subLayer) {
      yield* layer._visibleSubLayers();
    }
  }

  /// Gets a layer by its name.
  InfinityLayer? getLayerByName(String name) {
    for (final layer in _layersAndSubLayers()) {
      if (layer.name == name) return layer;
    }
    return null;
  }

  /// Gets a root layer or direct sublayer by z-index.
  InfinityLayer? getLayerSubByZIndex(int zIndex, {InfinityLayer? parent}) {
    final siblings = subLayer;
    for (final layer in siblings) {
      if (layer.zIndex == zIndex) return layer;
    }
    return null;
  }

  /// Gets a layer by its object.
  InfinityLayer? getLayerByObject(InfinityObject object) {
    for (final layer in _layersAndSubLayers()) {
      if (layer._objects.contains(object)) return layer;
    }
    return null;
  }

  /// Gets a list of layers by their visibility.
  List<InfinityLayer> getLayersByVisibility(bool isVisible) {
    return _layersAndSubLayers()
        .where((layer) => layer.isVisible == isVisible)
        .toList();
  }

  /// Gets a list of layers by their collidability.
  List<InfinityLayer> getLayersByCollidability(bool isCollidable) {
    return _layersAndSubLayers()
        .where((layer) => layer.isCollidable == isCollidable)
        .toList();
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
  /// - [_isVisible] determines if the layer is visible. If false, objects in this layer will not be rendered.
  /// - [_isCollidable] determines if objects in this layer can collide with objects in other layers. If false, collision checks will be
  InfinityLayer({
    required this.name,
    required this.zIndex,
    this._isVisible = true,
    this._isCollidable = true,
  });
}
