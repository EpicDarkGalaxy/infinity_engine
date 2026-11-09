import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hit_them/infinity_engine/infinity_engine.dart';

class InfinityTick extends StatefulWidget {
  final void Function(double deltaTime) onLogicTick;
  final double _logicFps;
  final double _renderFps;

  double get targetFps => _logicFps;
  double get renderFps => _renderFps;

  const InfinityTick({
    super.key,
    required this.onLogicTick,
    this._logicFps = 30.0,
    this._renderFps = 60.0,
  });

  @override
  State<InfinityTick> createState() => _InfinityTickState();
}

class _InfinityTickState extends State<InfinityTick>
    with TickerProviderStateMixin {
  late final Ticker _logicTicker;
  late final Ticker _renderTicker;

  // Logic
  Duration _lastLogicElapsed = Duration.zero;
  Duration _accumulatedLogicTime = Duration.zero;
  late final int _targetMicrosecondsPerFrame;

  // Render
  Duration _lastRenderElapsed = Duration.zero;
  Duration _accumulatedRenderTime = Duration.zero;
  late final int _targetRenderMicrosecondsPerFrame;

  @override
  void initState() {
    super.initState();
    debugPrint("InfinityTick initState");
    _targetMicrosecondsPerFrame = (1000000 / widget.targetFps).round();
    _targetRenderMicrosecondsPerFrame = (1000000 / widget.renderFps).round();

    // 1. FIXED-RATE LOGIC TICKER (Deterministic Physics & Scripts)
    _logicTicker = createTicker((elapsed) {
      if (_lastLogicElapsed != Duration.zero) {
        final frameDelta = elapsed - _lastLogicElapsed;
        _accumulatedLogicTime += frameDelta;

        while (_accumulatedLogicTime.inMicroseconds >=
            _targetMicrosecondsPerFrame) {
          final double dt = _targetMicrosecondsPerFrame / 1000000.0;
          widget.onLogicTick(dt);

          _accumulatedLogicTime -= Duration(
            microseconds: _targetMicrosecondsPerFrame,
          );
        }
      }
      _lastLogicElapsed = elapsed;
    });

    // 2. RENDER TICKER
    _renderTicker = createTicker((elapsed) {
      if (_lastRenderElapsed != Duration.zero) {
        final delta = elapsed - _lastRenderElapsed;
        _accumulatedRenderTime += delta;

        while (_accumulatedRenderTime.inMicroseconds >=
            _targetRenderMicrosecondsPerFrame) {
          for (var object in InfinityEngine().objects) {
            object.update();
          }

          _accumulatedRenderTime -= Duration(
            microseconds: _targetRenderMicrosecondsPerFrame,
          );
        }
      }
      _lastRenderElapsed = elapsed;
    });

    _logicTicker.start();
    _renderTicker.start();
  }

  @override
  void dispose() {
    _logicTicker.dispose();
    _renderTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
