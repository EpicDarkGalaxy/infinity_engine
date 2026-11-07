import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class InfinityTick extends StatefulWidget {
  final void Function(double deltaTime) tick;
  final double targetFps;

  const InfinityTick({
    super.key,
    required this.tick,
    this.targetFps = 30.0, // Default to 30 FPS cap
  });

  @override
  State<InfinityTick> createState() => _DeltaTimeState();
}

class _DeltaTimeState extends State<InfinityTick>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  Duration _accumulatedTime = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Calculate target interval per frame in microseconds
    // e.g., 30 FPS = 33,333 microseconds per frame
    final int targetMicrosecondsPerFrame = (1000000 / widget.targetFps).round();

    _ticker = createTicker((elapsed) {
      if (_lastElapsed != Duration.zero) {
        final frameDelta = elapsed - _lastElapsed;
        _accumulatedTime += frameDelta;

        // Check if enough time has passed for the next custom frame
        while (_accumulatedTime.inMicroseconds >= targetMicrosecondsPerFrame) {
          final double dt = targetMicrosecondsPerFrame / 1000000.0;
          final clampedDt = dt > 0.1 ? 0.1 : dt; // Prevent jumps on lag spikes
          widget.tick(clampedDt);

          // Subtract the target interval from the accumulator
          _accumulatedTime -= Duration(
            microseconds: targetMicrosecondsPerFrame,
          );
        }
      }
      _lastElapsed = elapsed;
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
