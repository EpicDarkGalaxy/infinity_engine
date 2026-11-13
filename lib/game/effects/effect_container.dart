import 'package:infinity_engine/game/effects/base_effect.dart';
import 'package:collection/collection.dart';

class EffectContainer {
  static List<BaseEffect> effects = [];

  static bool hasEffect(BaseEffect effect) {
    return effects.any((element) => element == effect);
  }

  /// Returns the first effect of type T, cast directly to T?
  static T? getEffect<T extends BaseEffect>() {
    return effects.firstWhereOrNull((element) => element is T) as T?;
  }

  static void addEffect(BaseEffect effect) {
    if (!hasEffect(effect)) effects.add(effect);
  }

  static void removeEffect(BaseEffect effect) {
    effects.remove(effect);
  }
}
