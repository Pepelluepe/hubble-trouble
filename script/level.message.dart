library levels.title;

import 'dart:html';

import 'keys.dart' as keys;
import 'level.generic.dart';
import 'sound.dart' as sound;


class LevelMessage extends Level {

    Context ctx;

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

        keys.up.one('any', this.handleAny);
    }

    void handleAny(e) {
        this.ttl = 0;
    }

    void cleanUp() {
        keys.up.off('any', this.handleAny);
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#111';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        ctx.fillStyle = '#fff';
        ctx.font = '40px VT323';
        ctx.fillText(
            this.message,
            ctx.canvas.width / 2 - ctx.measureText(this.message).width / 2,
            ctx.canvas.height / 2 - 20
        );
    }

    void tick(int delta) {
        this.ttl -= delta;
        if (this.ttl <= 0) {
            this.ctx.nextLevel();
        }
    }

}
