import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity_math/vector2.dart';
import 'package:hit_them/infinity_engine/infinity_input/infinity_input.dart';
import 'package:hit_them/infinity_engine/infinity_loop.dart';
import 'package:hit_them/infinity_engine/infinity_object.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';

class SnakeGame extends InfinityLoop {
  // Grid & Engine configuration
  final double tileSize = 20.0;
  final double moveInterval = 0.12; // Controls movement step speed (seconds)
  final double boundsWidth = 600.0;
  final double boundsHeight = 600.0;

  double _timeAccumulator = 0.0;
  bool isGameOver = false;

  // Snake Grid Logic
  final List<Vector2> _snakeSegments = [];
  Vector2 _currentDirection = Vector2.right;
  Vector2 _nextDirection = Vector2.right;

  // Engine Visual Objects
  final List<InfinityObject> _bodyObjects = [];
  late final InfinityObject foodObject;
  Vector2 _foodPosition = Vector2.zero;

  @override
  void start() {
    isGameOver = false;
    _timeAccumulator = 0.0;
    _currentDirection = Vector2.right;
    _nextDirection = Vector2.right;

    // 1. Clear any old objects in the engine if restarting
    _bodyObjects.clear();
    _snakeSegments.clear();

    // 2. Spawn initial 3-segment snake
    _snakeSegments.addAll([
      const Vector2(200, 200),
      const Vector2(180, 200),
      const Vector2(160, 200),
    ]);

    for (int i = 0; i < _snakeSegments.length; i++) {
      final obj = InfinityObject(
        state: InfinityObjectState(
          name: "Snake_$i",
          color: i == 0 ? Colors.green.shade800 : Colors.green,
          position: _snakeSegments[i],
          size: Size(
            tileSize - 2,
            tileSize - 2,
          ), // Subtle padding between grid tiles
        ),
      );
      _bodyObjects.add(obj);
      InfinityEngine().addObject(obj);
    }

    // 3. Initialize Food Object
    _spawnFoodPosition();
    foodObject = InfinityObject(
      state: InfinityObjectState(
        name: "Food",
        color: Colors.redAccent,
        position: _foodPosition,
        size: Size(tileSize - 2, tileSize - 2),
      ),
    );
    InfinityEngine().addObject(foodObject);
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    // Step 1: Buffer Input (Prevents instant self-reversal)
    if ((InfinityInput.isPressed(InfinityInput.keys.w) ||
            InfinityInput.isPressed(InfinityInput.keys.up)) &&
        _currentDirection != Vector2.down) {
      _nextDirection = Vector2.up;
    } else if ((InfinityInput.isPressed(InfinityInput.keys.s) ||
            InfinityInput.isPressed(InfinityInput.keys.down)) &&
        _currentDirection != Vector2.up) {
      _nextDirection = Vector2.down;
    } else if ((InfinityInput.isPressed(InfinityInput.keys.a) ||
            InfinityInput.isPressed(InfinityInput.keys.left)) &&
        _currentDirection != Vector2.right) {
      _nextDirection = Vector2.left;
    } else if ((InfinityInput.isPressed(InfinityInput.keys.d) ||
            InfinityInput.isPressed(InfinityInput.keys.right)) &&
        _currentDirection != Vector2.left) {
      _nextDirection = Vector2.right;
    }

    // Step 2: Grid Tick Accumulation
    _timeAccumulator += dt;
    if (_timeAccumulator >= moveInterval) {
      _timeAccumulator = 0.0;
      _currentDirection = _nextDirection;

      final Vector2 head = _snakeSegments.first;
      final Vector2 newHead = head + (_currentDirection * tileSize);

      // Step 3: Wall Collision Check
      if (newHead.x < 0 ||
          newHead.x >= boundsWidth ||
          newHead.y < 0 ||
          newHead.y >= boundsHeight) {
        _triggerGameOver("Hit the wall!");
        return;
      }

      // Step 4: Self Collision Check
      for (final segment in _snakeSegments) {
        if (segment.x == newHead.x && segment.y == newHead.y) {
          _triggerGameOver("Hit yourself!");
          return;
        }
      }

      // Step 5: Food Eating & Movement Logic
      final bool ateFood =
          (newHead.x == _foodPosition.x && newHead.y == _foodPosition.y);
      _snakeSegments.insert(0, newHead);

      if (ateFood) {
        // Grow snake: Create new render object in engine
        _spawnFoodPosition();
        foodObject.position = _foodPosition;

        final newBodyObj = InfinityObject(
          state: InfinityObjectState(
            name: "Snake_${_bodyObjects.length}",
            color: Colors.green,
            position: newHead,
            size: Size(tileSize - 2, tileSize - 2),
          ),
        );
        _bodyObjects.add(newBodyObj);
        InfinityEngine().addObject(newBodyObj);
      } else {
        // Normal move: Drop tail
        _snakeSegments.removeLast();
      }

      // Step 6: Sync Engine Visual Positions with Snake Grid Coordinates
      for (int i = 0; i < _snakeSegments.length; i++) {
        _bodyObjects[i].position = _snakeSegments[i];
      }
    }
  }

  void _spawnFoodPosition() {
    final random = Random();
    final int maxGridX = (boundsWidth / tileSize).floor();
    final int maxGridY = (boundsHeight / tileSize).floor();

    double x = random.nextInt(maxGridX) * tileSize;
    double y = random.nextInt(maxGridY) * tileSize;

    _foodPosition = Vector2(x, y);
  }

  void _triggerGameOver(String reason) {
    isGameOver = true;
    print("GAME OVER: $reason");
  }
}
