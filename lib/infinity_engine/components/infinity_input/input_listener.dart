import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_input/infinity_input.dart';

class InputListener extends StatefulWidget {
  const InputListener({super.key, required this.child});

  final Widget child;

  @override
  State<InputListener> createState() => _InputListenerState();
}

class _InputListenerState extends State<InputListener> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        return InfinityInput.handleKeyEvent(event);
      },
      child: Listener(
        onPointerDown: (event) {
          InfinityInput.pointerPosition = event.localPosition;
          InfinityInput.pointerDown = true;
          _focusNode.requestFocus();
        },
        onPointerMove: (event) {
          InfinityInput.pointerPosition = event.localPosition;
        },
        onPointerHover: (event) {
          InfinityInput.pointerPosition = event.localPosition;
        },
        onPointerUp: (event) {
          InfinityInput.pointerPosition = event.localPosition;
          InfinityInput.pointerDown = false;
        },
        onPointerCancel: (event) {
          InfinityInput.pointerDown = false;
        },
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: widget.child,
        ),
      ),
    );
  }
}
