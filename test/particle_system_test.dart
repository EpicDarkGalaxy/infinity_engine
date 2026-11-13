import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

void main() {
  test('emits particles and removes the burst after its lifetime', () {
    final engine = InfinityEngine();
    engine.init();

    final particles = ParticleSystem.burst(
      position: const Vector2(100, 100),
      color: Colors.orange,
      particleCount: 6,
      lifetime: 0.5,
      seed: 1,
    );

    engine.startEngine();
    expect(engine.objects.length, 7);

    particles.update(1);

    expect(engine.objects, isEmpty);
  });
}
