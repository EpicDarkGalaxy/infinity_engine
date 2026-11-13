import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_layer.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

/// A full-canvas Flutter UI element rendered on the engine's UI layer.
class InfinityUi extends InfinityObject {
  InfinityUi({
    super.key,
    required this.child,
    this.alignment = Alignment.topLeft,
    this.padding = EdgeInsets.zero,
    this.useSafeArea = true,
    this.ignorePointer = false,
    InfinityLayer? layer,
    String name = 'InfinityUi',
  }) : super(
         state: InfinityObjectState(
           name: name,
           layer: layer ?? InfinityLayer.uiLayer,
           size: Vector2.zero,
         ),
       );

  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;
  final bool useSafeArea;
  final bool ignorePointer;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        if (!state.visibility) return const SizedBox.shrink();

        Widget content = Align(
          alignment: alignment,
          child: Padding(padding: padding, child: this.child),
        );
        if (useSafeArea) content = SafeArea(child: content);
        if (ignorePointer) content = IgnorePointer(child: content);

        return Positioned.fill(child: content);
      },
    );
  }
}
