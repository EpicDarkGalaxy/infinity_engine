import 'package:flutter_test/flutter_test.dart';
import 'package:hit_them/infinity_engine/components/infinity_layer.dart';
import 'package:hit_them/infinity_engine/components/infinity_object.dart';

void main() {
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
