import 'package:flutter/material.dart';
import 'package:infinity_engine/game/effects/base_effect.dart';
import 'package:infinity_engine/game/effects/effect_container.dart';
import 'package:infinity_engine/infinity_engine/components.dart';
import 'package:infinity_engine/infinity_engine/infinity_engine.dart';

class GravityUp extends BaseEffect with InfinityLoop {
  GravityUp({required super.parent, required super.target}) {
    duration = 10;
  }

  late final ValueNotifier<int> timerNotifier;
  late final InfinityUi timerText;

  late final RigidBody _body;

  @override
  void apply() {
    final body = target.getComponent<RigidBody>();
    if (body == null) return;
    _body = body;
    _body.gravityScale = 1.5;
    isActive = true;
  }

  @override
  void update(double dt) {
    if (isActive) {
      duration -= dt;
      timerNotifier.value = duration.toInt();
      if (duration <= 0) {
        isActive = false;
        _body.gravityScale = 1;
        EffectContainer.removeEffect(this);
        InfinityEngine.removeObject(timerText);
        parent.removeLoop(this);
      }
    }
  }

  @override
  void start() {
    final oldEffect = EffectContainer.getEffect<GravityUp>();
    if (oldEffect != null) {
      oldEffect.duration += duration;
      return;
    }
    timerNotifier = ValueNotifier(duration.toInt());
    timerText = buildUI(
      timerNotifier,
      const EdgeInsets.fromLTRB(16, 100, 16, 16),
      "Gravity Boost",
    );
    InfinityEngine.addObject(timerText);
    EffectContainer.addEffect(this);
    apply();
  }
}
