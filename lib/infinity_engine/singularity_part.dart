part of 'infinity_engine.dart';

class Singularity extends flutter.StatelessWidget {
  const Singularity({super.key, required this.rootLoop});

  final SingularityLoop rootLoop;

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.MaterialApp(
      home: flutter.Scaffold(
        body: InputListener(
          child: flutter.SizedBox.expand(
            child: flutter.Stack(
              children: [
                InfinityTick(
                  onLogicTick: (dt) {
                    InfinityEngine()._loop(dt);
                  },
                  renderFps: InfinityEngine().fps,
                  logicFps: InfinityEngine().fps,
                ),
                flutter.Positioned.fill(child: InfinityEngine()._canvasWidget),
                InfinityEngine().debugMode
                    ? flutter.Positioned.fill(
                        child: flutter.IgnorePointer(
                          child: flutter.CustomPaint(
                            painter: ColliderDebugPainter(
                              engine: InfinityEngine(),
                            ),
                          ),
                        ),
                      )
                    : flutter.SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void runApp(Singularity gameWidget) {
  final rootObject = InfinityObject(
    state: InfinityObjectState(name: "rootLoop", color: flutter.Colors.black),
    loops: [gameWidget.rootLoop, InfinityTime()],
  )..isVisible = false;
  InfinityEngine.addObject(rootObject);
  flutter.runApp(gameWidget);
  InfinityEngine().startEngine();
}

// I could have simply use the InfinityLoop but i wanted a seprate loop for the first or rootLoop
/// First Loop of the game
class SingularityLoop extends InfinityLoop {
  @override
  void update(dt) {}

  @override
  void start() {}
}
