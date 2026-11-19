import 'package:flutter/foundation.dart';
import 'package:infinity_engine/components.dart';
import 'package:infinity_engine/engine.dart';
import 'package:infinity_engine/src/components/infinity_log.dart';
import 'package:infinity_engine/src/infinity_container.dart';

class InfinityScene extends ChangeNotifier {
  InfinityScene({this.name = 'InfinityScene', this._onLoad, this._onUnload})
    : _layers = _createDefaultLayers();

  final void Function(InfinityScene scene)? _onLoad;
  final void Function()? _onUnload;

  final String name;
  final List<InfinityLayer> _layers;
  final InfinityContainer _container = InfinityContainer();
  final Set<InfinityObject> _pendingStartObjects = {};

  static List<InfinityLayer> _createDefaultLayers() => [
    InfinityLayer(name: 'Default Layer', zIndex: 0),
    InfinityLayer(name: 'UI Layer', zIndex: 10000, isCollidable: false),
  ];

  List<InfinityLayer> get layers => List.unmodifiable(_layers);
  InfinityContainer get container => _container;

  @internal
  bool isActive = false;
  bool _isLoaded = false;
  bool _isActivating = false;
  bool _sceneStartPending = false;

  @internal
  void activate() {
    isActive = true;
    if (!_isLoaded) {
      _isActivating = true;
      try {
        onLoad();
        _onLoad?.call(this);
      } catch (_) {
        isActive = false;
        rethrow;
      } finally {
        _isActivating = false;
      }

      _isLoaded = true;
      _sceneStartPending = this is InfinityLoop;
    }

    _startPendingObjects();
    if (_sceneStartPending) {
      _sceneStartPending = false;
      final loop = this as InfinityLoop;
      if (InfinityEngine().isRunning) {
        loop.start();
      } else {
        InfinityEngine.addStartCallback(loop.start);
      }
    }
  }

  @internal
  void deactivate() {
    isActive = false;
    onUnload();
    _onUnload?.call();
  }

  @internal
  void purge() {
    for (final object in _container.objects) {
      _container.removeObject(object);
      object.layer.removeObject(object);
    }
    _layers
      ..clear()
      ..addAll(_createDefaultLayers());
    _pendingStartObjects.clear();
    _isLoaded = false;
    _sceneStartPending = false;
  }

  @override
  @internal
  void dispose() {
    deactivate();
    super.dispose();
  }

  /// Called when a new or purged scene is activated.
  /// This is not called again when a preserved scene is reactivated.
  void onLoad() {}

  /// Called whenever the scene is deactivated.
  void onUnload() {}

  /// Adds an object to the scene.
  void addObject(InfinityObject object) {
    if (_container.containsObject(object)) {
      InfinityLog.e('Object [${object.name}] already exists in scene');
      return;
    }
    final layer = getLayerByName(object.layer.name);
    if (layer == null) {
      throw StateError(
        'Layer "${object.layer.name}" does not exist in scene "$name".',
      );
    }
    if (!identical(layer, object.layer)) {
      object.state.layer = layer;
    }
    _container.addObject(object);
    layer.addObject(object);
    InfinityLog.i('Added object "${object.state.name}" to the $name scene');
    if (isActive && !_isActivating) {
      InfinityEngine().handleStartCallback(object);
    } else {
      _pendingStartObjects.add(object);
    }
  }

  /// Removes an object from the scene.
  void removeObject(InfinityObject object) {
    if (!_container.containsObject(object)) {
      InfinityLog.e('Object [${object.name}] does not exist in scene');
      return;
    }
    final layer = object.layer;
    _container.removeObject(object);
    _pendingStartObjects.remove(object);
    layer.removeObject(object);
  }

  T? getObject<T extends InfinityObject>() {
    return _container.getObjectByType<T>();
  }

  void _startPendingObjects() {
    for (final object in _pendingStartObjects.toList()) {
      if (_container.containsObject(object)) {
        InfinityEngine().handleStartCallback(object);
      }
    }
    _pendingStartObjects.clear();
  }

  // Helper
  bool _zIndex(int index) {
    for (final InfinityLayer layer in layers) {
      if (layer.zIndex == index) {
        return true;
      }
    }
    return false;
  }

  /// Adds a layer to the scene.
  void addLayer(InfinityLayer layer) {
    if (layers.contains(layer)) {
      InfinityLog.e('Layer [${layer.name}] already exists in scene');
      return;
    }
    if (_zIndex(layer.zIndex)) {
      InfinityLog.e('A layer with ${layer.zIndex} already exists');
    }
    _layers.add(layer);
    _sortLayers();
    if (isActive) notifyListeners();
  }

  /// Removes a layer from the scene.
  void removeLayer(InfinityLayer layer) {
    if (!layers.contains(layer)) {
      InfinityLog.e('Layer [${layer.name}] does not exist in scene');
      return;
    }
    _layers.remove(layer);
    _sortLayers();
    if (isActive) notifyListeners();
  }

  /// Gets a layer or sublayer by name.
  InfinityLayer? getLayerByName(String name) {
    for (final layer in layers) {
      if (layer.name == name) {
        return layer;
      } else {
        final subLayer = layer.getLayerByName(name);
        if (subLayer != null) {
          return subLayer;
        }
      }
    }
    return null;
  }

  void _sortLayers() {
    _layers.sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }
}
