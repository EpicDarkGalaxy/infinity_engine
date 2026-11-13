import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_math/vector2.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_layer.dart';
import 'package:infinity_engine/infinity_engine/components/infinity_object.dart';

void main() {
  test('batches visual state notifications until update', () {
    final state = InfinityObjectState();
    var notifications = 0;
    state.addListener(() => notifications++);

    state.position = const Vector2(10, 20);
    state.color = Colors.blue;
    expect(notifications, 0);

    state.update();
    expect(notifications, 1);

    state.update();
    expect(notifications, 1);
  });

  testWidgets('visibility can hide and restore an object', (tester) async {
    final object = InfinityObject(
      key: const ValueKey('visibility-object'),
      state: InfinityObjectState(),
    );
    await tester.pumpWidget(MaterialApp(home: object));
    final renderedObject = find.descendant(
      of: find.byKey(const ValueKey('visibility-object')),
      matching: find.byType(Transform),
    );
    expect(renderedObject, findsWidgets);

    object.visibility = false;
    await tester.pump();
    expect(renderedObject, findsNothing);

    object.visibility = true;
    await tester.pump();
    expect(renderedObject, findsWidgets);
  });

  group('InfinityObject layer state', () {
    test('initializes and changes layer through state without mutable widget fields', () {
      final customLayer = InfinityLayer(name: 'Overlay', zIndex: 5);
      InfinityLayer.addLayer(customLayer);
      addTearDown(() => InfinityLayer.removeLayer(customLayer));

      final state = InfinityObjectState(layer: customLayer);
      final object = InfinityObject(state: state);
      var notifications = 0;
      state.addListener(() => notifications++);

      expect(object.layer, same(customLayer));

      object.layer = InfinityLayer.defaultLayer;

      expect(object.layer, same(InfinityLayer.defaultLayer));
      expect(notifications, 1);
    });
  });
}
