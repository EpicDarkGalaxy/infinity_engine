import 'package:flutter/material.dart';
import 'package:infinity_engine/game/effects/base_effect.dart';
import 'package:infinity_engine/game/effects/effect_container.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class NoGround extends BaseEffect with InfinityLoop {
  NoGround({required this.parent, required this.target});
  final InfinityObject parent;
  final InfinityObject target;

  double effectDuration = 10;
  bool isActive = false;

  late final ValueNotifier<int> timerNotifer;
  late final InfinityUi timerText;

  void apply() {
    target.hide();
    target.layer.isCollidable = false;
    isActive = true;
  }

  @override
  void update(double dt) {
    if (isActive) {
      effectDuration -= dt;
      timerNotifer.value = effectDuration.toInt();
      if (effectDuration <= 0) {
        target.visibility = true;
        target.layer.isCollidable = true;
        isActive = false;
        EffectContainer.removeEffect(this);
        InfinityEngine.removeObject(timerText);
        parent.removeLoop(this);
      }
    }
  }

  @override
  void start() {
    final hasEffect = EffectContainer.effects.any(
      (element) => element is NoGround,
    );
    if (hasEffect) {
      final effect = EffectContainer.effects.firstWhere(
        (element) => element is NoGround,
      ) as NoGround;
      if (effect.isActive) {
        effect.effectDuration += effectDuration;
        effect.timerNotifer.value = effect.effectDuration.toInt();
      }
      return;
    }
    timerNotifer = ValueNotifier<int>(effectDuration.toInt());
    timerText = InfinityUi(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      name: "NoGround UI",
      child: ValueListenableBuilder<int>(
        valueListenable: timerNotifer,
        builder: (context, value, child) {
          return Text(
            " NoGround: $value",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          );
        },
      ),
    );
    InfinityEngine.addObject(timerText);
    EffectContainer.addEffect(this);
    apply();
  }
}
