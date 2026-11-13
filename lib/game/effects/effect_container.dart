import 'package:infinity_engine/game/effects/base_effect.dart';

class EffectContainer {
  static List<BaseEffect> effects = [];

  static void addEffect(BaseEffect effect) {
    effects.add(effect);
  }

  static void removeEffect(BaseEffect effect) {
    effects.remove(effect);
  }
}
