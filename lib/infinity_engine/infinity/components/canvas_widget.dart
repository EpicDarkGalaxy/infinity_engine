import 'package:flutter/material.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key, required this.objects});

  final List<Widget> objects;

  void addObject(Widget object) {
    objects.add(object);
  }

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  @override
  Widget build(BuildContext context) {
    print(widget.objects);
    return Stack(children: widget.objects);
  }
}
