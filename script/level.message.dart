library levels.title;

import 'dart:html';

import 'images.dart' as images;
import 'level.generic.dart';
import 'sound.dart' as sound;


class LevelMessage extends Level {

    Context ctx;

    images.Drawable image;
    int duration;
    String message;

    int ttl;

    LevelMessage(Context ctx, int duration, String message) {
        this.ctx = ctx;
        this.duration = duration;
        this.message = message;
    }

    void reset() {
        this.ttl = this.duration;
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#111';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        ctx.fillStyle = '#fff';
        ctx.font = '50px VT323';
        ctx.fillText(
            this.message,
            canvas.width / 2 - ctx.measureText(this.message).width / 2,
            canvas.height / 2 - 25
        );
    }

    void tick(int delta) {
        this.ttl -= delta;
        if (this.ttl <= 0) {
            this.ctx.nextLevel();
        }
    }

}
