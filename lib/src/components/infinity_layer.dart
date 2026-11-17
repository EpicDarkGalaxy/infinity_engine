import 'package:flutter/foundation.dart';
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

  static final sceneChanges = ChangeNotifier();

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

  /// List of all layers in the engine.
  static final List<InfinityLayer> layers = [defaultLayer, uiLayer];

  void _notifySceneChanged() {
    sceneChanges.notifyListeners();
    notifyListeners();
  }

  /// Adds an object to the layer specified in the object's state.
  static void addObject(InfinityObject object) {
    final layer = getLayerByName(object.layer.name);
    if (layer != null) {
      if (!identical(layer, object.layer)) object.state.layer = layer;
      if (!layer._objects.contains(object)) {
        layer._objects.add(object);
        layer._notifySceneChanged();
      }
    } else {
      throw StateError("Layer ${object.layer.name} does not exist.");
    }
  }

  /// Moves an object to a new layer.
  @internal
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
    currentLayer?.notifyListeners();
    targetLayer.notifyListeners();
    sceneChanges.notifyListeners();
  }

  /// Removes an object from its layer.
  static void removeObject(InfinityObject object) {
    final layer = getLayerByObject(object) ?? getLayerByName(object.layer.name);
    if (layer == null) {
      throw StateError("Layer ${object.layer.name} does not exist.");
    }
    if (layer._objects.remove(object)) {
      layer._notifySceneChanged();
    }
  }

  // Helper to sort layers by zIndex.
  static void _sortLayers(List<InfinityLayer> layers) {
    layers.sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }

  /// Adds a layer to the engine.
  static void addLayer(InfinityLayer layer) {
    if (layers.contains(layer)) return;
    if (layers.any((existing) => existing.zIndex == layer.zIndex)) {
      throw StateError(
        "A layer [${layer.name}] with z-index ${layer.zIndex} already exists.",
      );
    }
    layers.add(layer);
    _sortLayers(layers);
    sceneChanges.notifyListeners();
  }

  /// Creates and registers a root layer. If [zIndex] is omitted, the layer is
  /// assigned the next index after the current highest root layer.
  static InfinityLayer createLayer({
    required String name,
    int? zIndex,
    bool isVisible = true,
    bool isCollidable = true,
  }) {
    final layer = InfinityLayer(
      name: name,
      zIndex: zIndex ?? _nextZIndex(layers),
      isVisible: isVisible,
      isCollidable: isCollidable,
    );
    addLayer(layer);
    return layer;
  }

  /// Removes a layer from the engine.
  static void removeLayer(InfinityLayer layer) {
    layers.remove(layer);
    sceneChanges.notifyListeners();
  }

  static void addSubLayer(InfinityLayer layer, InfinityLayer subLayer) {
    if (layer._subLayers.contains(subLayer)) return;
    if (layer._subLayers.any(
      (existing) => existing.zIndex == subLayer.zIndex,
    )) {
      throw StateError(
        "A sublayer [${subLayer.name}] with z-index ${subLayer.zIndex} already exists under ${layer.name}.",
      );
    }
    layer._subLayers.add(subLayer);
    _sortLayers(layer._subLayers);
    layer._notifySceneChanged();
  }

  /// Creates and attaches a sublayer. If [zIndex] is omitted, it receives the
  /// next index after the current highest sibling.
  static InfinityLayer createSubLayer({
    required InfinityLayer parent,
    required String name,
    int? zIndex,
    bool isVisible = true,
    bool isCollidable = true,
  }) {
    final subLayer = InfinityLayer(
      name: name,
      zIndex: zIndex ?? _nextZIndex(parent._subLayers),
      isVisible: isVisible,
      isCollidable: isCollidable,
    );
    addSubLayer(parent, subLayer);
    return subLayer;
  }

  static int _nextZIndex(Iterable<InfinityLayer> siblings) {
    int? maxZIndex;
    for (final layer in siblings) {
      if (maxZIndex == null || layer.zIndex > maxZIndex) {
        maxZIndex = layer.zIndex;
      }
    }
    return maxZIndex == null ? 0 : maxZIndex + 1;
  }

  static void removeSubLayer(InfinityLayer layer, InfinityLayer subLayer) {
    if (layer._subLayers.remove(subLayer)) {
      layer._notifySceneChanged();
    }
  }

  Iterable<InfinityLayer> _layersAndSubLayers() sync* {
    yield this;
    for (final subLayer in _subLayers) {
      yield* subLayer._layersAndSubLayers();
    }
  }

  static Iterable<InfinityLayer> _allLayers() sync* {
    for (final layer in layers) {
      yield* layer._layersAndSubLayers();
    }
  }

  Iterable<InfinityLayer> _visibleLayers() sync* {
    if (!isVisible) return;
    yield this;
    for (final subLayer in _subLayers) {
      yield* subLayer._visibleLayers();
    }
  }

  static Iterable<InfinityLayer> get visibleLayers sync* {
    for (final layer in layers) {
      yield* layer._visibleLayers();
    }
  }

  /// Gets a layer by its name.
  static InfinityLayer? getLayerByName(String name) {
    for (final layer in _allLayers()) {
      if (layer.name == name) return layer;
    }
    return null;
  }

  /// Gets a root layer or direct sublayer by z-index.
  static InfinityLayer? getLayerByZIndex(int zIndex, {InfinityLayer? parent}) {
    final siblings = parent?._subLayers ?? layers;
    for (final layer in siblings) {
      if (layer.zIndex == zIndex) return layer;
    }
    return null;
  }

  /// Gets a layer by its object.
  static InfinityLayer? getLayerByObject(InfinityObject object) {
    for (final layer in _allLayers()) {
      if (layer._objects.contains(object)) return layer;
    }
    return null;
  }

  /// Gets a list of layers by their visibility.
  static List<InfinityLayer> getLayersByVisibility(bool isVisible) {
    return _allLayers().where((layer) => layer.isVisible == isVisible).toList();
  }

  /// Gets a list of layers by their collidability.
  static List<InfinityLayer> getLayersByCollidability(bool isCollidable) {
    return _allLayers()
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
