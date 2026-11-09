import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_engine/infinity_engine/components.dart';

void main() {
  testWidgets('renders a child on the UI layer', (tester) async {
    final ui = InfinityUi(
      alignment: Alignment.center,
      child: const Text('LIVES 3'),
    );

    expect(ui.layer, same(InfinityLayer.uiLayer));

    await tester.pumpWidget(MaterialApp(home: Stack(children: [ui])));

    expect(find.text('LIVES 3'), findsOneWidget);
  });
}
