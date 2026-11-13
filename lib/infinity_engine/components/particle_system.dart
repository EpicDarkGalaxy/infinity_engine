import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_layer.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_loop.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

/// Emits a one-shot radial burst of short-lived colored particles.
class ParticleSystem with InfinityLoop {
  ParticleSystem._({
    required Vector2 position,
    required this._color,
    required this._layer,
    required this._particleCount,
    required this._minSpeed,
    required this._maxSpeed,
    required this._lifetime,
    required this._gravity,
    required this._particleSize,
    required int? seed,
  }) : _origin = position,
       _random = Random(seed),
       _host = InfinityObject(
         state: InfinityObjectState(
           name: 'ParticleSystem',
           color: Colors.transparent,
           layer: _layer,
         )..visibility = false,
       ) {
    _host.addLoop(this);
  }

  final Vector2 _origin;
  final Color _color;
  final InfinityLayer _layer;
  final int _particleCount;
  final double _minSpeed;
  final double _maxSpeed;
  final double _lifetime;
  final double _gravity;
  final double _particleSize;
  final Random _random;
  final InfinityObject _host;
  final List<_Particle> _particles = [];
  bool _started = false;

  /// Creates and registers a radial burst with the current engine.
  static ParticleSystem burst({
    required Vector2 position,
    Color color = Colors.white,
    InfinityLayer? layer,
    int particleCount = 16,
    double minSpeed = 45,
    double maxSpeed = 180,
    double lifetime = 0.55,
    double gravity = 260,
    double particleSize = 7,
    int? seed,
  }) {
    assert(particleCount > 0);
    assert(minSpeed >= 0);
    assert(maxSpeed >= minSpeed);
    assert(lifetime > 0);
    assert(particleSize > 0);

    final system = ParticleSystem._(
      position: position,
      color: color,
      layer: layer ?? InfinityLayer.defaultLayer,
      particleCount: particleCount,
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      lifetime: lifetime,
      gravity: gravity,
      particleSize: particleSize,
      seed: seed,
    );
    InfinityEngine.addObject(system._host);
    return system;
  }

  @override
  void start() {
    if (_started) return;
    _started = true;

    for (var index = 0; index < _particleCount; index++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _minSpeed + _random.nextDouble() * (_maxSpeed - _minSpeed);
      final size = _particleSize * (0.65 + _random.nextDouble() * 0.7);
      final particle = InfinityObject(
        state: InfinityObjectState(
          name: 'Particle',
          position: _origin,
          size: Vector2(size, size),
          color: _color,
          layer: _layer,
        ),
      );
      _particles.add(
        _Particle(
          object: particle,
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          lifetime: _lifetime * (0.75 + _random.nextDouble() * 0.5),
        ),
      );
      InfinityEngine.addObject(particle);
    }
  }

  @override
  void update(double dt) {
    for (var index = _particles.length - 1; index >= 0; index--) {
      final particle = _particles[index];
      particle.age += dt;
      if (particle.age >= particle.lifetime) {
        InfinityEngine.removeObject(particle.object);
        _particles.removeAt(index);
        continue;
      }

      particle.velocity = particle.velocity + Vector2(0, _gravity * dt);
      particle.object.position =
          particle.object.position + particle.velocity * dt;
      particle.object.color = _color.withValues(
        alpha: 1 - particle.age / particle.lifetime,
      );
    }

    if (_particles.isEmpty) {
      InfinityEngine.removeObject(_host);
    }
  }
}

class _Particle {
  _Particle({
    required this.object,
    required this.velocity,
    required this.lifetime,
  });

  final InfinityObject object;
  final double lifetime;
  Vector2 velocity;
  double age = 0;
}
