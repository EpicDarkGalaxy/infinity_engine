import 'package:infinity_engine/game/effects/base_effect.dart';
import 'package:infinity_engine/game/effects/effect_container.dart';

class NoGround extends BaseEffect {
  NoGround({required super.parent, required super.target}) {
    duration = 10;
  }

  @override
  void apply() {
    target.hide();
    target.layer.isCollidable = false;
    kickTimer();
  }

  @override
  void onTimerEnd() {
    target.visibility = true;
    target.layer.isCollidable = true;
    isActive = false;
    EffectContainer.removeEffect(this);
    removeUI();
  }

  @override
  void start() {
    final oldEffect = EffectContainer.getEffect<NoGround>();
    if (oldEffect != null) {
      oldEffect.duration += duration;
      return;
    }
    buildUI("No Ground");
    EffectContainer.addEffect(this);
    apply();
  }
}
