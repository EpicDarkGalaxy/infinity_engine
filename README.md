# Infinity Engine

Experimental 2D game engine built with Flutter and Dart.

This project is a small, game-oriented engine for creating scene-based experiences using layered objects, loops, physics, inputs, and a canvas-rendered scene graph. It is still early-stage and evolving, so APIs may change while the engine is being developed.

## Features

- Layered scene objects with z-order support
- Game loop orchestration via `InfinityLoop`
- Simple object model with transforms, visibility, color, and size
- Physics primitives such as `RigidBody` and `AABBCollider`
- Input handling via `InfinityInput`
- Particle effects through `ParticleSystem`
- A `Singularity` widget that wraps the engine in a Flutter app

## Installation

Add the package to your Flutter project:

```bash
dart pub add infinity_engine
```

Or add it directly to your `pubspec.yaml`:

```yaml
dependencies:
  infinity_engine: ^0.0.1
```

Then fetch dependencies:

```bash
flutter pub get
```

## Basic usage

```dart
import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine.dart';

void main() {
  runApp(Singularity(rootLoop: GameLoop()));
}

class GameLoop with InfinityLoop {
  @override
  void start() {
    final player = InfinityObject(
      state: InfinityObjectState(
        name: 'player',
        position: const Vector2(120, 120),
        size: const Vector2(32, 32),
        color: Colors.blue,
      ),
    );

    player.addComponent(RigidBody());
    player.addComponent(AABBCollider());

    InfinityEngine.addObject(player);
  }

  @override
  void update(double dt) {
    // Update game logic here.
  }
}
```

## Engine lifecycle

Use the singleton engine to register objects and manage runtime flow:

```dart
final engine = InfinityEngine();
engine.init();
engine.startEngine();
```

You can add objects directly:

```dart
final sprite = InfinityObject(
  state: InfinityObjectState(
    name: 'sprite',
    position: const Vector2(0, 0),
    size: const Vector2(64, 64),
    color: Colors.red,
  ),
);

InfinityEngine.addObject(sprite);
```

## Layers

Objects can be assigned to layers with different z-indices:

```dart
final background = InfinityLayer(name: 'Background', zIndex: 0);
final foreground = InfinityLayer(name: 'Foreground', zIndex: 10);

final ship = InfinityObject(
  state: InfinityObjectState(
    name: 'ship',
    layer: foreground,
  ),
);

ship.layer = background;
```

## Physics and components

The engine exposes several component-style building blocks:

```dart
final body = InfinityObject(
  state: InfinityObjectState(name: 'body'),
);

body.addComponent(RigidBody(object: body));
body.addComponent(AABBCollider(object: body));
```

`RigidBody` and `AABBCollider` are intended for collision and motion integration, while custom game logic can be attached by extending `InfinityLoop` or adding additional components.

## Particle system

```dart
final burst = ParticleSystem.burst(
  position: const Vector2(200, 200),
  color: Colors.orange,
  particleCount: 12,
  lifetime: 0.5,
);

InfinityEngine.addObject(burst);
```

## Notes

- The package is currently experimental and may not yet provide a complete polished API.
- The project is oriented toward lightweight 2D game development in Flutter.
- For the most up-to-date behavior, inspect the source under `lib/infinity_engine` and the test coverage in `test/`.

## License

This project is licensed under the MIT license. See the `LICENSE` file for details.
