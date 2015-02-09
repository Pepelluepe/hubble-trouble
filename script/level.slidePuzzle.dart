library levels.menu;

import 'dart:html';
import 'dart:typed_data';

import 'audio.dart' as audio;
import 'base64.dart' as base64;
import 'drawutils.dart' as drawutils;
import 'images.dart' as images;
import 'keys.dart' as keys;
import 'level.generic.dart';
import 'levels.dart' as levels;
import 'settings.dart' as settings;
import 'sound.dart' as sound;
import 'tiles.dart' as tiles;


const String CARET = '> ';
const String ANTI_CARET = '  ';
const String START_GAME = 'START GAME';
const String PASSWORD = 'PASSWORD: ';

var TILES_PER_ROW = settings.sprite_tile_row;
var TILES_RATIO = settings.tile_size / settings.sprite_tile_size;
var TILES_RATIO_INV = settings.sprite_tile_size / settings.tile_size;


class LevelSlidePuzzle extends Level {

    Context ctx;

    images.Drawable bgImage;
    images.Drawable playerSprite;
    images.Drawable trinketSprite;

    CanvasRenderingContext2D board;
    Uint16List data;

    int trinketIndex;
    int width;
    int height;
    int duration;

    int startX, startY;
    int endX, endY;
    double playerX, playerY;
    bool playerSliding;
    double playerVelX, playerVelY;
    int playerDirX, playerDirY;

    int won;

    LevelSlidePuzzle(Context ctx, int trinketIndex, int width, int height, Object data) {
        this.ctx = ctx;
        this.trinketIndex = trinketIndex;
        this.width = width;
        this.height = height;

        this.bgImage = images.get('space');
        this.playerSprite = images.get('player');
        this.trinketSprite = images.get('trinkets');

        this.data = new Uint16List(width * height);
        if (data != null) {
            var convertedData = base64.base64DecToArr(data);
            for (var i = 0; i < this.data.length; i++) {
                this.data[i] = convertedData[i];
            }
        }

        this.board = drawutils.getBuffer(
            width * settings.sprite_tile_size,
            height * settings.sprite_tile_size
        );
        images.get('tiles').drawEventually((img) {
            var tile;
            var tileImg;
            for (var x = 0; x < width; x++) {
                for (var y = 0; y < height; y++) {
                    tile = this.data[this.getLevelIndex(x, y)];
                    if (tile == tiles.TILE_EMPTY) continue;

                    tileImg = tiles.IMAGES[tile];

                    if (tile == tiles.TILE_START) {
                        this.startX = x;
                        this.startY = y;
                    }

                    if (tile == tiles.TILE_END) {
                        this.endX = x;
                        this.endY = y;
                    }

                    this.board.drawImageScaledFromSource(
                        img,
                        tileImg % TILES_PER_ROW * settings.sprite_tile_size,
                        (tileImg / TILES_PER_ROW).floor() * settings.sprite_tile_size,
                        settings.sprite_tile_size,
                        settings.sprite_tile_size,
                        x * settings.sprite_tile_size,
                        y * settings.sprite_tile_size,
                        settings.sprite_tile_size,
                        settings.sprite_tile_size
                    );
                }
            }
        });

    }

    int getLevelIndex(int x, int y) {
        if (x < 0) x = 0;
        else if (x >= this.width) x = this.width - 1;
        if (y < 0) y = 0;
        else if (y >= this.height) y = this.height - 1;

        return y * this.width + x;
    }

    void reset() {
        this.won = 0;

        this.playerX = this.startX;
        this.playerY = this.startY;
        this.playerSliding = false;
        this.playerVelX = 0;
        this.playerVelY = 0;
        this.playerDirX = 0;
        this.playerDirY = 0;

        keys.up.on('any', this.handleKey);

    }

    void cleanUp() {
        keys.up.off('any', this.handleKey);
    }

    void handleKey(e) {
        if (playerSliding) return false;
        switch (e.keyCode) {
            case 37: // Left
                doSlide(-1, 0);
                break;
            case 38: // Up
                doSlide(0, -1);
                break;
            case 39: // Right
                doSlide(1, 0);
                break;
            case 40: // Down
                doSlide(0, 1);
                break;
        }
    }

    void doSlide(int dx, int dy) {
        if (!playerCanMove(dx, dy)) return;

        playerDirX = dx;
        playerDirY = dy;
        playerVelX = dx * 0.01;
        playerVelY = dy * 0.01;
        playerX += playerVelX;
        playerY += playerVelY;
        playerSliding = true;

        sound.play('move');
    }

    bool playerCanMove(int dx, int dy) {
        if (dx < 0 && playerX.round() == 0) return false;
        if (dx > 0 && playerX.round() == this.width - 1) return false;
        if (dy < 0 && playerY.round() == 0) return false;
        if (dy > 0 && playerY.round() == this.height - 1) return false;

        return tiles.isPassable(this.data[this.getLevelIndex(playerX.round() + dx, playerY.round() + dy)]);
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        var canvas = ctx.canvas;

        var now = new DateTime.now().millisecondsSinceEpoch;

        var finalWidth, finalHeight;
        var offsetX, offsetY;

        this.bgImage.draw((img) {
            var fitYWidth = canvas.height / img.height * img.width;
            var fitYHeight = canvas.height;
            var fitXWidth = canvas.width;
            var fitXHeight = canvas.width / img.width * img.height;

            var xOrY = fitYWidth > canvas.width;
            finalWidth = xOrY ? fitXWidth : fitYWidth;
            finalHeight = xOrY ? fitXHeight : fitYHeight;

            var hw = finalWidth / 2;
            var hh = finalHeight / 2;

            offsetX = canvas.width / 2 - hw;
            offsetY = canvas.height / 2 - hh;
            ctx.drawImageScaledFromSource(
                img,
                0, 0,
                img.width, img.height,
                offsetX, offsetY,
                finalWidth, finalHeight
            );
        });

        ctx.drawImageScaledFromSource(
            this.board.canvas,
            0, 0,
            this.board.canvas.width, this.board.canvas.height,
            offsetX, offsetY,
            finalWidth, finalHeight
        );

        var tileSize = finalWidth / this.width;
        if (this.won == 0) {
            this.trinketSprite.draw((img) {
                var now = new DateTime.now().millisecondsSinceEpoch;
                var wiggleVal = tileSize / 16;
                ctx.drawImageScaledFromSource(
                    img,
                    this.trinketIndex % 2 * 16, (this.trinketIndex / 2).floor() * 16, 16, 16,
                    offsetX + tileSize * this.endX + ((now / 2 % 976 / 250).floor() % 3 - 1) * wiggleVal,
                    offsetY + tileSize * this.endY + ((now / 2 % 873 / 250).floor() % 3 - 1) * wiggleVal,
                    tileSize, tileSize
                );
            });
        }

        this.playerSprite.draw((img) {
            ctx.drawImageScaledFromSource(
                img,
                0, 0, 16, 16,
                offsetX + tileSize * this.playerX,
                offsetY + tileSize * this.playerY,
                tileSize, tileSize
            );
        });

    }

    void tick(int delta) {
        if (this.won != 0) {
            this.won -= delta;
            if (this.won <= 0) {
                this.won = 0;
                this.ctx.nextLevel();
            }
            return;
        }

        if (!this.playerSliding) {
            return;
        }

        var origPlayerX = playerX;
        var origPlayerY = playerY;

        playerX += playerVelX * delta;
        playerY += playerVelY * delta;

        if (origPlayerX.floor() != playerX.floor() ||
            origPlayerY.floor() != playerY.floor()) {
            // The player has crossed into a new tile.

            if (!playerCanMove(playerDirX, playerDirY)) {
                playerDirX = 0;
                playerDirY = 0;
                playerVelX = 0;
                playerVelY = 0;
                playerX = playerX.round();
                playerY = playerY.round();
                playerSliding = false;

                if (playerX == endX && playerY == endY) {
                    sound.play('select');
                    this.won = 500;
                    return;
                }

                sound.play('bump');
                return;
            }

        }

    }

}
