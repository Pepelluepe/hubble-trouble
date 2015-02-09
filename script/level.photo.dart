library levels.title;

import 'dart:html';

import 'drawutils.dart' as drawutils;
import 'images.dart' as images;
import 'level.generic.dart';
import 'mouse.dart' as mouse;
import 'sound.dart' as sound;


class LevelPhoto extends Level {

    Context ctx;

    images.Drawable bgImage;
    CanvasRenderingContext2D blurredImage;

    int ttl;
    int holdTimer;
    int sliderVal;
    int lastSliderVal;
    bool sliding;

    LevelPhoto(Context ctx, String image) {
        this.ctx = ctx;
        this.bgImage = images.get(image);

        this.blurredImage = drawutils.getBuffer(512, 512);
    }

    void reset() {
        this.ttl = -1;
        this.holdTimer = -1;
        this.sliding = false;
        this.sliderVal = 20;
        this.lastSliderVal = 0;

        mouse.events.on('down', this.handleMouseDown);
        mouse.events.on('up', this.handleMouseUp);
        mouse.events.on('move', this.handleMouseMove);
    }

    void handleMouseDown(e) {
        if (this.ttl != -1) return;
        if ((e.clientY - document.body.clientHeight * 0.75).abs() > 35) return;
        if ((e.clientX - (document.body.clientWidth / 2 - 150 + this.sliderVal * 3)).abs() > 35) return;

        this.sliding = true;
    }

    void handleMouseUp(e) {
        if (!this.sliding) return;
        if (this.ttl != -1) return;

        this.sliding = false;
    }

    void handleMouseMove(e) {
        if (!this.sliding) return;
        if (this.ttl != -1) return;
        var val = (e.clientX - document.body.clientWidth / 2 + 150) / 3;
        if (val < 0) val = 0;
        else if (val > 100) val = 100;
        this.sliderVal = val;
    }

    void cleanUp() {
        mouse.events.off('down', this.handleMouseDown);
        mouse.events.off('up', this.handleMouseUp);
        mouse.events.off('move', this.handleMouseMove);
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        var canvas = ctx.canvas;
        ctx.fillStyle = '#111';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);


        var fitYWidth = canvas.height / this.blurredImage.canvas.height * this.blurredImage.canvas.width;
        var fitYHeight = canvas.height;
        var fitXWidth = canvas.width;
        var fitXHeight = canvas.width / this.blurredImage.canvas.width * this.blurredImage.canvas.height;

        var xOrY = fitYWidth > canvas.width;
        var finalWidth = xOrY ? fitXWidth : fitYWidth;
        var finalHeight = xOrY ? fitXHeight : fitYHeight;

        var hw = finalWidth / 2;
        var hh = finalHeight / 2;
        ctx.drawImageScaledFromSource(
            this.blurredImage.canvas,
            0, 0, 512, 512,
            canvas.width / 2 - hw,
            canvas.height / 2 - hh,
            finalWidth, finalHeight
        );

        if (this.ttl != -1) return;

        ctx.fillStyle = '#333';
        ctx.fillRect(
            document.body.clientWidth / 2 - 150,
            document.body.clientHeight * 0.75 - 5,
            300,
            10
        );

        ctx.fillStyle = '#aaa';
        ctx.fillRect(
            document.body.clientWidth / 2 - 150 + this.sliderVal * 3 - 35,
            document.body.clientHeight * 0.75 - 35,
            70,
            70
        );

    }

    void tick(int delta) {
        if (this.ttl != -1) {
            this.ttl -= delta;
            if (this.ttl <= 0) {
                this.ctx.nextLevel();
            }
            return;
        }

        if (this.sliderVal != this.lastSliderVal) {
            this.bgImage.draw((img) {
                this.blurredImage.drawImage(img, 0, 0);
                var radius = (this.sliderVal - 50).abs().round();
                if (radius != 0) {
                    drawutils.blur(this.blurredImage, radius);
                }

                if (radius < 3 && this.holdTimer == -1) {
                    this.holdTimer = 1500;
                } else if (radius > 3) {
                    this.holdTimer = -1;
                }
            });
            sound.play('tick');
            this.lastSliderVal = this.sliderVal;

        }

        if (this.holdTimer != -1) {
            this.holdTimer -= delta;
            if (this.holdTimer <= 0) {
                // Play success sound
                sound.play('select');
                // Draw clearest version of image
                this.bgImage.draw((img) {
                    this.blurredImage.drawImage(img, 0, 0);
                });
                this.ttl = 1000;
                return;
            }
        }


    }

}
