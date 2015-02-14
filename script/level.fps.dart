library levels.fps;

import 'dart:html';
import 'dart:math';

import 'images.dart' as images;
import 'keys.dart' as keys;
import 'level.generic.dart';
import 'sound.dart' as sound;


const FPS_PLAYER_SPEED = 1.0;
const PIXEL_WIDTH = 5;
const SAMPLES = 75;
const TEXTURE_SIZE = 16;


/**
 * This file is a partial port of Canvascape by Benjamin Joffe.
 * http://www.benjoffe.com/code/demos/canvascape/textures
 *
 *
 * Copyright (c) 2009, Benjamin Joffe
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


class LevelFPS extends Level {

    Context ctx;

    images.Drawable bgImage;
    images.Drawable textures;

    Uint16List data;
    List<double> bits;
    List<double> distances;
    List<int> faces;

    int width;
    int height;

    double rotation;
    double x = 0, y = 0, z = 0;
    double startX, startY;

    int pressingUD;
    int pressingLR;

    LevelFPS(Context ctx, Object data, int width, int height, double x, double y) {
        this.ctx = ctx;

        this.data = data;
        this.width = width;
        this.height = height;
        this.x = this.startX = x;
        this.y = this.startY = y;

        this.textures = images.get('threedeetextures');
    }

    void reset() {
        this.rotation = 0;
        this.x = this.startX;
        this.y = this.startY;
        this.z = 0;
        this.bits = new List<double>(SAMPLES);
        this.distances = new List<double>(SAMPLES);
        this.faces = new List<int>(SAMPLES);

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

    void calcWallDistance(double theta) {
        var deltaX, deltaY;
        var distX, distY;
        var stepX, stepY;
        var mapX, mapY;

        var atX = this.x.floor();
        var atY = this.y.floor();

        for (var i = 0; i < SAMPLES; i++) {
            theta += PI / 3 / SAMPLES + 2 * PI;
            theta %= 2 * PI;

            mapX = atX;
            mapY = atY;

            deltaX = 1 / cos(theta);
            deltaY = 1 / sin(theta);

            if (deltaX > 0) {
                stepX = 1;
                distX = (mapX + 1 - x) * deltaX;
            } else {
                stepX = -1;
                deltaX *= -1;
                distX = (x - mapX) * deltaX;
            }
            if (deltaY > 0) {
                stepY = 1;
                distY = (mapY + 1 - y) * deltaY;
            } else {
                stepY = -1;
                deltaY *= -1;
                distY = (y - mapY) * deltaY;
            }

            var dval;
            while (true) {
                if (distX < distY) {
                    mapX += stepX;
                    dval = this.data[this.getLevelIndex(mapX, mapY)];
                    if (dval != 0) {
                        this.distances[i] = distX;
                        this.faces[i] = dval;
                        this.bits[i] = (y + distX / deltaY * stepY) % 1;
                        break;
                    }
                    distX += deltaX;
                } else {
                    mapY += stepY;
                    dval = this.data[this.getLevelIndex(mapX, mapY)];
                    if (dval != 0) {
                        this.distances[i] = distY;
                        this.faces[i] = dval;
                        this.bits[i] = (x + distY / deltaX * stepX) % 1;
                        break;
                    }
                    distY += deltaY;
                }
            }
        }
    }

    int getLevelIndex(int x, int y) {
        if (x < 0) x = 0;
        else if (x >= this.width) x = this.width - 1;
        if (y < 0) y = 0;
        else if (y >= this.height) y = this.height - 1;

        return y * this.width + x;
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#111';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        var theta = this.rotation - PI / 6;
        this.calcWallDistance(theta);

        var c;
        for (var i = 0; i < SAMPLES; i++) {
            theta += PI / 3 / SAMPLES;

            var d2 = this.distances[i];
            var d = d2 * cos(theta - this.rotation);

            var z = 1 - this.z / 2;

            this.textures.draw((img) {
                var face = this.faces[i];
                var h = 300 / d;
                ctx.drawImage(
                    img,
                    this.bits[i] * (TEXTURE_SIZE - 1) + (face % 4) * TEXTURE_SIZE,
                    (face / 4).floor() * TEXTURE_SIZE,
                    1,
                    TEXTURE_SIZE,
                    i * PIXEL_WIDTH,
                    150 - h * z,
                    PIXEL_WIDTH,
                    h
                );
            });

        }
    }

    void tick(int delta) {
        if (this.pressingLR == 1) {
            this.rotation += delta * 0.005;
        } else if (this.pressingLR == 2) {
            this.rotation -= delta * 0.005;
        }

        var dX = 0.0;
        var dY = 0.0;
        if (this.pressingUD != 0) {
            dX = FPS_PLAYER_SPEED * cos(this.rotation) * delta * 0.001;
            dY = FPS_PLAYER_SPEED * sin(this.rotation) * delta * 0.001;
        }

        if (this.pressingUD == 1) {
            this.x += dX;
            this.y += dX;
        } else if (this.pressingUD == 2) {
            this.x -= dX;
            this.y -= dX;
        }
    }

}
