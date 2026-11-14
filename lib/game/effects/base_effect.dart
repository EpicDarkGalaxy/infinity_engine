import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:flutter/material.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class BaseEffect extends ChangeNotifier with InfinityLoop {
  BaseEffect({required this.parent, required this.target});

  final InfinityObject parent;
  final InfinityObject target;

  bool isActive = false;
  double duration = 0;
  final ValueNotifier<int> timerNotifier = ValueNotifier(0);
  late final Widget timerText;

  static ChangeNotifier hudNotifier = ChangeNotifier();
  static List<Widget> effectHud = [];
  static late final InfinityUi hudContainer;
  static bool hudBuilt = false;

  void buildUI(String name) {
    if (!hudBuilt) {
      hudBuilt = true;
      hudContainer = InfinityUi(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        name: "effects",
        child: ListenableBuilder(
          listenable: hudNotifier,
          builder: (context, child) {
            return Column(children: effectHud);
          },
        ),
      );
      InfinityEngine.addObject(hudContainer);
    }
    timerText = ValueListenableBuilder<int>(
      valueListenable: timerNotifier,
      builder: (context, value, child) {
        return Text(
          "$name: $value",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        );
      },
    );
    effectHud.add(timerText);
    hudNotifier.notifyListeners();
  }

  void removeUI() {
    effectHud.remove(timerText);
    hudNotifier.notifyListeners();
  }

  void onTimerEnd() {}

  void kickTimer() {
    isActive = true;
  }

  void apply() {}

  @override
  void update(double dt) {
    if (isActive) {
      duration -= dt;
      timerNotifier.value = duration.toInt();
      if (duration <= 0) {
        isActive = false;
        onTimerEnd();
        removeUI();
      }
    }
  }

  @override
  void start() {
    // TODO: implement start
  }
}
