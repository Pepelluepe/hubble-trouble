library levels.menu;

import 'dart:html';

import 'audio.dart' as audio;
import 'images.dart' as images;
import 'keys.dart' as keys;
import 'level.generic.dart';
import 'levels.dart' as levels;
import 'sound.dart' as sound;


const String CARET = '> ';
const String ANTI_CARET = '  ';
const String START_GAME = 'START GAME';
const String PASSWORD = 'PASSWORD: ';


class LevelMenu extends Level {

    Context ctx;

    images.Drawable bgImage;
    images.Drawable hubbleImage;
    int duration;

    bool ended;
    int jump;
    int pointerIndex = 0;
    String passwordVal = '';

    LevelMenu(Context ctx) {
        this.ctx = ctx;

        this.bgImage = images.get('menu');
        this.hubbleImage = images.get('menu_hubble');
    }

    void reset() {
        this.ended = false;
        this.jump = 0;

        this.pointerIndex = 0;

        keys.up.on(40, this.handleDown); // Down
        keys.up.on(38, this.handleUp); // Up
        keys.up.on(13, this.handleSelect); // Enter

        keys.up.on('any', this.handleKey);

    }

    void cleanUp() {
        keys.up.off(40, this.handleDown);
        keys.up.off(38, this.handleUp);
        keys.up.off(13, this.handleSelect);
        keys.up.off('any', this.handleKey);
    }

    void handleUp(e) {
        this.pointerIndex = this.pointerIndex == 0 ? 1 : 0;
        sound.play('menu_up');
    }

    void handleDown(e) {
        this.pointerIndex = this.pointerIndex == 0 ? 1 : 0;
        sound.play('menu_down');
    }

    void handleSelect(e) {
        if (this.pointerIndex == 0) {
            this.ended = true;
            sound.play('select');
            return;
        } else if (this.pointerIndex == 1) {
            if (this.passwordVal.length != 3) {
                sound.play('invalid_choice');
                return;
            }

            var level = ctx.passwordTest(this.passwordVal);
            if (level == -1) {
                sound.play('bad_choice');
                return;
            }

            sound.play('select');
            this.jump = level;
            this.ended = true;
        }

    }

    void handleKey(e) {
        if (this.pointerIndex == 0) return;
        if (e.keyCode == keys.BACKSPACE) {
            e.preventDefault();
            if (this.passwordVal.length == 0) {
                sound.play('invalid_choice');
                return;
            }
            this.passwordVal = this.passwordVal.substring(0, this.passwordVal.length - 1);
            sound.play('backspace');
            return;
        }
        if (keys.CHAR_CODES.containsKey(e.keyCode)) {

            if (this.passwordVal.length == 3) {
                sound.play('invalid_choice');
                return;
            }

            this.passwordVal += keys.CHAR_CODES[e.keyCode];
            sound.play('keypress');
        }
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        var canvas = ctx.canvas;

        var now = new DateTime.now().millisecondsSinceEpoch;

        var finalWidth;
        var finalHeight;
        var hw;
        var hh;

        this.bgImage.draw((img) {
            var fitYWidth = canvas.height / img.height * img.width;
            var fitYHeight = canvas.height;
            var fitXWidth = canvas.width;
            var fitXHeight = canvas.width / img.width * img.height;

            var xOrY = fitYWidth > canvas.width;
            finalWidth = xOrY ? fitXWidth : fitYWidth;
            finalHeight = xOrY ? fitXHeight : fitYHeight;

            hw = finalWidth / 2;
            hh = finalHeight / 2;
            ctx.drawImageScaledFromSource(
                img,
                0, 0,
                img.width, img.height,
                canvas.width / 2 - hw,
                canvas.height / 2 - hh,
                finalWidth, finalHeight
            );
        });

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

        ctx.fillStyle = '#fff';
        ctx.font = '50px VT323';
        ctx.fillText(
            (this.pointerIndex == 0 ? CARET : ANTI_CARET) + START_GAME,
            canvas.width / 2 - hw + 10,
            canvas.height / 2 + hh - 120
        );
        ctx.fillText(
            (this.pointerIndex == 1 ? CARET : ANTI_CARET) + PASSWORD + this.passwordVal,
            canvas.width / 2 - hw + 10,
            canvas.height / 2 + hh - 60
        );

    }

    void tick(int delta) {
        if (this.ended) {
            if (this.jump != 0) {
                this.ctx.goto(this.jump);
            } else {
                this.ctx.nextLevel();
            }
        }
    }

}
