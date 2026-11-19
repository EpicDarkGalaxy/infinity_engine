import 'package:flutter/material.dart';
import 'package:infinity_engine/src/components/infinity_layer.dart';
import 'package:infinity_engine/src/components/infinity_math/vector2.dart';
import 'package:infinity_engine/src/components/infinity_object.dart';

/// A Flutter UI overlay element rendered on the engine's UI layer (or a custom layer).
///
/// Supports two modes:
/// - **Screen-aligned** (`useWorldPosition = false`): Aligns [child] within the
///   viewport using [alignment], [padding], and [useSafeArea], offset by [position].
/// - **World-positioned** (`useWorldPosition = true`): Translates [child] directly
///   to `(state.position.x, state.position.y)` in top-left canvas coordinates,
///   ideal for floating health bars or combat text.
class InfinityUi extends InfinityObject {
  InfinityUi({
    super.key,
    required this.child,
    this.alignment = Alignment.topLeft,
    this.padding = EdgeInsets.zero,
    Vector2 position = Vector2.zero,
    this.useSafeArea = true,
    this.ignorePointer = false,
    this.useWorldPosition = false,
    InfinityLayer? layer,
    String name = 'InfinityUi',
  }) : super(
         state: InfinityObjectState(
           name: name,
           layer: layer ?? InfinityLayer.uiLayer,
           size: Vector2.zero,
         ),
       ) {
    state.position = position;
    state.update();
  }

  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;
  final bool useSafeArea;
  final bool ignorePointer;
  final bool useWorldPosition;

  /// Updates [position] and immediately flushes the state change so the UI moves.
  void setUiPosition(Vector2 newPosition) {
    state.position = newPosition;
    state.update();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([state, layer]),
      builder: (context, _) {
        if (!state.visibility || !layer.isVisible) {
          return const SizedBox.shrink();
        }

        Widget body;
        if (useWorldPosition) {
          body = Transform.translate(
            offset: state.position.toOffset,
            child: child,
          );
          if (ignorePointer) {
            body = IgnorePointer(child: body);
          }
          body = Align(alignment: Alignment.topLeft, child: body);
        } else {
          body = Align(
            alignment: alignment,
            child: Padding(padding: padding, child: child),
          );
          if (useSafeArea) {
            body = SafeArea(child: body);
          }
          if (ignorePointer) {
            body = IgnorePointer(child: body);
          }
          if (state.position.x != 0 || state.position.y != 0) {
            body = Transform.translate(
              offset: state.position.toOffset,
              child: body,
            );
          }
        }

        return Positioned.fill(child: body);
      },
    );
  }
}
