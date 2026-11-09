import 'dart:math' as math;

import 'package:flutter/material.dart';

class Vector2 {
  const Vector2(this.x, this.y);

  final double x;
  final double y;

  static const Vector2 zero = Vector2(0, 0);
  static const Vector2 one = Vector2(1, 1);
  static const Vector2 up = Vector2(0, -1);
  static const Vector2 down = Vector2(0, 1);
  static const Vector2 left = Vector2(-1, 0);
  static const Vector2 right = Vector2(1, 0);

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);
  Vector2 operator /(double scalar) => Vector2(x / scalar, y / scalar);
  Vector2 operator -() => Vector2(-x, -y);

  double get magnitude => math.sqrt(x * x + y * y);

  double get magnitudeSquared => x * x + y * y;

  Vector2 get normalized {
    final mag = magnitude;
    if (mag == 0) return Vector2.zero;
    return this / mag;
  }

  Vector2 get perpendicular => Vector2(-y, x);

  Vector2 get abs => Vector2(x.abs(), y.abs());

  Offset get toOffset => Offset(x, y);

  Size get toSize => Size(x, y);

  double distanceTo(Vector2 other) => (this - other).magnitude;

  double dot(Vector2 other) => x * other.x + y * other.y;

  double cross(Vector2 other) => x * other.y - y * other.x;

  Vector2 lerp(Vector2 other, double t) =>
      Vector2(x + (other.x - x) * t, y + (other.y - y) * t);

  Vector2 clamp(Vector2 min, Vector2 max) =>
      Vector2(x.clamp(min.x, max.x), y.clamp(min.y, max.y));

  @override
  String toString() => 'Vector2($x, $y)';
}
