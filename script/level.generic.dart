library levels.generic;

import 'dart:html';
import 'dart:typed_data';


abstract class Level {

    int height;
    int width;

    CanvasRenderingContext2D ctx;
    Uint16List data;

    void draw(CanvasRenderingContext2D ctx, Function drawUI);

    void reset();
    void cleanUp() {}

    void tick(int delta);

    int getLevelIndex(int x, int y) {
        return 0;
    }

    bool canPause() => false;

}

typedef bool passwordTestFunc(String x);
typedef void nextLevelFunc();
class Context {
    final passwordTestFunc passwordTest;
    final nextLevelFunc nextLevel;
    Context(this.passwordTest, this.nextLevel);
}
