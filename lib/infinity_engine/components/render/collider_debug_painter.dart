import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_physics/colliders/base_collider.dart';

class ColliderDebugPainter extends CustomPainter {
  final InfinityEngine engine;
  final Color borderColor;
  final double strokeWidth;

  ColliderDebugPainter({
    required this.engine,
    this.borderColor = Colors.redAccent,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Loop through all active objects in the engine
    for (var object in engine.objects) {
      for (var component in object.components) {
        if (component is BaseCollider) {
          // Draw wireframe rect using the collider's live position and size
          final rect = Rect.fromLTWH(
            component.position.x,
            component.position.y,
            component.size!.x,
            component.size!.y,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ColliderDebugPainter oldDelegate) => true;
}
