# Infinity Engine

Infinity Engine is an experimental 2D game engine built with Flutter and Dart.
The repository is engine-first; **Hit Them** is a sample game used to exercise
the engine during development, not the main product.

# Note

Ai was used in the making of the engine.

## Repository Layout

- `lib/infinity_engine/`: engine loop, object container, rendering, input, and
  physics components.
- `lib/game/`: Hit Them sample-game logic.
- `test/`: engine and widget tests.

## Run the Sample Game

Requires the Flutter SDK.

```sh
flutter pub get
flutter run
```

The current sample lets you move horizontally and jump while enemies fall from
the top of the screen. Colliding with an enemy increases the score and speeds
up the next wave.

## Controls

- Left and Right Arrow: move
- Space: jump

Run the test suite with:

```sh
flutter test
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
