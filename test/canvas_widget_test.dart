import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/components/render/canvas_widget.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

void main() {
  testWidgets('renders the scene canvas with debug mode disabled', (
    tester,
  ) async {
    final engine = InfinityEngine();
    engine.init();
    engine.debugMode = false;

    final object = InfinityObject(
      key: const ValueKey('scene-object'),
      state: InfinityObjectState(size: const Vector2(32, 32)),
    );
    InfinityEngine.addObject(object);

    await tester.pumpWidget(Singularity(rootLoop: SingularityLoop()));

    expect(tester.getSize(find.byType(CanvasWidget)), isNot(Size.zero));
    expect(find.byKey(const ValueKey('scene-object')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    InfinityEngine.removeObject(object);
  });

  group('CanvasController', () {
    test('reuses ordered objects until the canvas changes', () {
      final controller = CanvasController();
      final background = Container();
      controller.addObject(0, background);
      final firstSnapshot = controller.objects;

      expect(identical(firstSnapshot, controller.objects), isTrue);

      controller.addObject(1, Container());

      expect(identical(firstSnapshot, controller.objects), isFalse);
    });

    test(
      'orders layers by z-index and preserves insertion order within layers',
      () {
        final controller = CanvasController();
        final foregroundFirst = Container();
        final background = Container();
        final foregroundSecond = Container();
        final behindBackground = Container();

        controller.addObject(10, foregroundFirst);
        controller.addObject(0, background);
        controller.addObject(10, foregroundSecond);
        controller.addObject(-1, behindBackground);

        expect(controller.objects, [
          behindBackground,
          background,
          foregroundFirst,
          foregroundSecond,
        ]);
      },
    );
  });

  testWidgets('reports the canvas logical size from its layout constraints', (
    tester,
  ) async {
    final controller = CanvasController();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 320,
            height: 240,
            child: CanvasWidget(controller: controller),
          ),
        ),
      ),
    );

    final canvasSize = controller.getCanvasSize();
    expect(canvasSize.x, 320);
    expect(canvasSize.y, 240);
  });

  group('CanvasController removal', () {
    test('removes objects from the specified layer', () {
      final controller = CanvasController();
      final object = Container();
      final otherObject = Container();
      controller.addObject(0, object);
      controller.addObject(1, otherObject);

      controller.removeObject(0, object);

      expect(controller.objects, [otherObject]);
    });
  });
}
