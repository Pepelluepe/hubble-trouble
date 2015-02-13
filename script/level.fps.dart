library levels.fps;

import 'dart:html';

import 'images.dart' as images;
import 'keys.dart' as keys;
import 'level.generic.dart';
import 'sound.dart' as sound;


class LevelFPS extends Level {

    Context ctx;

    images.Drawable bgImage;
    images.Drawable textures;

    CanvasRenderingContext2D board;
    Uint16List data;

    double rotation;
    double x, y;

    int pressingUD;
    int pressingLR;

    LevelFPS(Context ctx, Object data) {
        this.ctx = ctx;
        this.data = data;

        this.textures = images.get('threedeetextures');
    }

    void reset() {
        this.rotation = 0;
        this.x = 0;
        this.y = 0;

        this.pressingLR = 0;
        this.pressingUD = 0;

        keys.down.on('any', this.handleDown);
        keys.up.on('any', this.handleUp);
    }

    void handleDown(e) {
        if (e.keyCode == 40) { // Down
            this.pressingUD = 2;
        } else if (e.keyCode == 38) { // Up
            this.pressingUD = 1;
        } else if (e.keyCode == 37) { // Left
            this.pressingLR = 1;
        } else if (e.keyCode == 39) { // Right
            this.pressingLR = 2;
        } else {
            return;
        }
    }

    void handleUp(e) {
        if (e.keyCode == 40) { // Down
            this.pressingUD = 0;
        } else if (e.keyCode == 38) { // Up
            this.pressingUD = 0;
        } else if (e.keyCode == 37) { // Left
            this.pressingLR = 0;
        } else if (e.keyCode == 39) { // Right
            this.pressingLR = 0;
        } else {
            return;
        }
    }

    void cleanUp() {
        keys.down.off('any', this.handleDown);
        keys.up.off('any', this.handleUp);
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#111';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    }

    void tick(int delta) {
        if (this.pressingLR == 1) {
            this.rotation += delta * 0.01;
        } else if (this.pressingLR == 2) {
            this.rotation -= delta * 0.01;
        }
        if (this.pressingUD == 1) {
            // this.rotation += delta * 0.01;
        } else if (this.pressingUD == 2) {
            // this.rotation -= delta * 0.01;
        }
    }

}
