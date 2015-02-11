library levels.title;

import 'dart:html';

import 'images.dart' as images;
import 'level.generic.dart';
import 'sound.dart' as sound;


class LevelTitle extends Level {

    Context ctx;

    images.Drawable image;
    int duration;
    String soundName;

    int ttl;

    LevelTitle(Context ctx, int duration, {String soundName: null}) {
        this.ctx = ctx;
        this.image = images.get('bastacorp');
        this.duration = duration;
        this.soundName = soundName;
    }

    void reset() {
        if (this.soundName != null) {
            sound.play(this.soundName);
        }

        this.ttl = this.duration;
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#111';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        this.image.draw((img) {
            var hw = img.width / 2;
            var hh = img.height / 2;
            ctx.drawImageScaledFromSource(
                img,
                0, 0,
                img.width, img.height,
                ctx.canvas.width / 2 - hw,
                ctx.canvas.height / 2 - hh,
                img.width, img.height
            );
        });
    }

    void tick(int delta) {
        this.ttl -= delta;
        if (this.ttl <= 0) {
            this.ctx.nextLevel();
        }
    }

}
