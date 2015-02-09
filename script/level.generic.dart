library levels.generic;

import 'dart:html';


abstract class Level {

    int height;
    int width;

    void draw(CanvasRenderingContext2D ctx, Function drawUI);

    void reset();
    void cleanUp() {}

    void tick(int delta);

    int getLevelIndex(int x, int y) {
        return 0;
    }

    bool canPause() => false;

}

typedef int passwordTestFunc(String x);
typedef void nextLevelFunc();
typedef void gotoFunc(int level);
class Context {
    final passwordTestFunc passwordTest;
    final nextLevelFunc nextLevel;
    final gotoFunc goto;
    Context(this.passwordTest, this.nextLevel, this.goto);
}
