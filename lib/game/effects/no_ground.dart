import 'package:flutter/material.dart';
import 'package:infinity_engine/game/effects/base_effect.dart';
import 'package:infinity_engine/game/effects/effect_container.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class NoGround extends BaseEffect with InfinityLoop {
  NoGround({required super.parent, required super.target}) {
    duration = 10;
  }

  late final ValueNotifier<int> timerNotifer;
  late final InfinityUi timerText;

  @override
  void apply() {
    target.hide();
    target.layer.isCollidable = false;
    isActive = true;
  }

  @override
  void update(double dt) {
    if (isActive) {
      duration -= dt;
      timerNotifer.value = duration.toInt();
      if (duration <= 0) {
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
    final oldEffect = EffectContainer.getEffect<NoGround>();
    if (oldEffect != null) {
      oldEffect.duration += duration;
      return;
    }
    timerNotifer = ValueNotifier<int>(duration.toInt());
    timerText = buildUI(
      timerNotifer,
      const EdgeInsets.fromLTRB(16, 50, 16, 16),
      "No Ground",
    );
    InfinityEngine.addObject(timerText);
    EffectContainer.addEffect(this);
    apply();
  }
}
