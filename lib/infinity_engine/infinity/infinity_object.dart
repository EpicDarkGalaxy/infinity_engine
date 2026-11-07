import 'package:flutter/material.dart';
import 'package:hit_them/infinity_engine/infinity/infinity_loop.dart';

class InfinityObjectState extends ChangeNotifier {
  final String id;
  final String name;
  final Color color;
  final Offset position;
  final Size size;
  final BoxShape shape;

  InfinityObjectState({
    required this.id,
    required this.name,
    required this.color,
    required this.position,
    required this.size,
    required this.shape,
  });

  set position(Offset position) {
    position = position;
    notifyListeners();
  }
}

class InfinityObject extends StatelessWidget {
  InfinityObject({
    super.key,
    required this.id,
    required this.name,
    required this.color,
    required this.position,
    required this.size,
    required this.shape,
    this.loops,
  }) {
    _state = InfinityObjectState(
      id: id,
      name: name,
      color: color,
      position: position,
      size: size,
      shape: shape,
    );
  }

  late final InfinityObjectState _state;
  final String id;
  final String name;
  final Color color;
  final Offset position;
  final Size size;
  final BoxShape shape;

  final List<InfinityLoop>? loops;

  set position(Offset position) {
    _state.position = position;
  }

  @override
  Widget build(BuildContext context) {
    print("Update ${_state.position}");
    return ListenableBuilder(
      listenable: _state,
      builder: (context, child) {
        return Transform.translate(
          offset: _state.position,
          child: Stack(
            children: [
              Container(
                width: _state.size.width,
                height: _state.size.height,
                decoration: BoxDecoration(
                  shape: _state.shape,
                  color: _state.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
