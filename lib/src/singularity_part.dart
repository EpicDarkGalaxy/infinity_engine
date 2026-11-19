part of 'infinity_engine.dart';

/// The main widget that runs the Infinity Engine. It sets up the game loop and renders the game canvas.
class Singularity extends flutter.StatelessWidget {
  const Singularity({super.key, required this.defaultScene});

  final SingularityLoop defaultScene;

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
                    : const flutter.SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void runApp(Singularity gameWidget) {
  InfinitySceneManager().addScene(gameWidget.defaultScene);
  final rootObject = InfinityObject(
    state: InfinityObjectState(name: "rootLoop", color: flutter.Colors.black),
    loops: [InfinityTime()],
  )..hide();
  InfinitySceneManager().switchTo(gameWidget.defaultScene);
  InfinityEngine.addObject(rootObject, addToScene: false);
  InfinityEngine().startEngine();
  flutter.runApp(gameWidget);
}

class SingularityLoop extends InfinityScene with InfinityLoop {
  @override
  void update(dt) {}

  @override
  void start() {}
}
