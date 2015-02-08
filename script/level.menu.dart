library levels.menu;

import 'dart:html';

import 'audio.dart' as audio;
import 'images.dart' as images;
import 'keys.dart' as keys;
import 'level.generic.dart';
import 'sound.dart' as sound;


class LevelMenu extends Level {

    images.Drawable bgImage;
    images.Drawable hubbleImage;
    int duration;

    bool ended;

    LevelMenu() {
        this.bgImage = images.get('menu');
        this.hubbleImage = images.get('menu_hubble');
    }

    void reset() {
        this.ended = false;

        keys.down.one('any', (e) {sound.play('select');});
        keys.up.one('any', (e) {this.ended = true;});
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        var canvas = ctx.canvas;

        var now = new DateTime.now().millisecondsSinceEpoch;

        this.bgImage.draw((img) {
            var fitYWidth = canvas.height / img.height * img.width;
            var fitYHeight = canvas.height;
            var fitXWidth = canvas.width;
            var fitXHeight = canvas.width / img.width * img.height;

            var xOrY = fitYWidth > canvas.width;
            var finalWidth = xOrY ? fitXWidth : fitYWidth;
            var finalHeight = xOrY ? fitXHeight : fitYHeight;

            var hw = finalWidth / 2;
            var hh = finalHeight / 2;
            ctx.drawImageScaledFromSource(
                img,
                0, 0,
                img.width, img.height,
                canvas.width / 2 - hw,
                canvas.height / 2 - hh,
                finalWidth, finalHeight
            );

            this.hubbleImage.draw((img) {
                ctx.save();

                ctx.translate(canvas.width * 0.55, canvas.height * 0.6);
                ctx.rotate(now / 20000 % 360);

                ctx.drawImageScaledFromSource(
                    img,
                    0, 0,
                    img.width, img.height,
                    -1 * hw / 2, // canvas.width / 2 - hw / 2,
                    -1 * hh / 2, // canvas.height / 2 - hh / 2,
                    finalWidth * 0.5, finalHeight * 0.5
                );
                ctx.restore();
            });
        });

    }

    void tick(int delta, Function nextLevel) {
        if (this.ended) {
            nextLevel();
        }
    }

}
