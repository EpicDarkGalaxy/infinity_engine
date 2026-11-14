import 'package:infinity_engine/game/effects/base_effect.dart';
import 'package:infinity_engine/game/effects/effect_container.dart';
import 'package:infinity_engine/infinity_engine/components.dart';

class GravityUp extends BaseEffect {
  GravityUp({required super.parent, required super.target}) {
    duration = 10;
  }

  late final RigidBody _body;

  @override
  void apply() {
    final body = target.getComponent<RigidBody>();
    if (body == null) return;
    _body = body;
    _body.gravityScale = 1.5;

    kickTimer();
  }

  @override
  void onTimerEnd() {
    isActive = false;
    _body.gravityScale = 1;
    EffectContainer.removeEffect(this);
    parent.removeLoop(this);
  }

  @override
  void start() {
    final oldEffect = EffectContainer.getEffect<GravityUp>();
    if (oldEffect != null) {
      oldEffect.duration += duration;
      return;
    }

    buildUI("Gravity Boost");
    EffectContainer.addEffect(this);
    apply();
  }
}
