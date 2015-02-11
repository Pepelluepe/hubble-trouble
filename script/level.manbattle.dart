library levels.photo;

import 'dart:math';

import 'drawutils.dart' as drawutils;
import 'images.dart' as images;
import 'keys.dart' as keys;
import 'level.generic.dart';
import 'sound.dart' as sound;


const MOVEMENT_INCREMENT = 20;
const CARET = '> ';
const ANTICARET = '  ';

var INSULTING_MOVES = [
    'SAME-DAY SHIPPING',
    'HANDCART',
    'LARGE PACKAGE',
];
var MOVES = [
    'SHOUT',
    'PUNCH',
    'CRY',
    'POUT',
];

var rng = new Random();


class LevelManbattle extends Level {

    Context ctx;

    // images.Drawable bgImage;
    images.Drawable player;
    images.Drawable upsGuy;

    bool ended;
    int countdown;
    int opponentHP;
    int stage;
    int selectedMove;
    String message1;
    String message2;

    LevelManbattle(Context ctx) {
        this.ctx = ctx;
        // this.bgImage = images.get(image);
        this.player = images.get('player');
        this.upsGuy = images.get('upsGuy');
    }

    void reset() {
        this.ended = false;
        this.countdown = 1500;
        this.opponentHP = 100;
        this.stage = 0;
        this.selectedMove = 0;
        this.message1 = 'DELIVERY GUY appears';
        this.message2 = '';

        keys.up.on('any', this.handleKey);
    }

    void cleanUp() {
        keys.up.off('any', this.handleKey);
    }

    void draw(CanvasRenderingContext2D ctx, Function drawUI) {
        var canvas = ctx.canvas;

        var squareSize = min(canvas.width, canvas.height);
        var squareX = canvas.width / 2 - squareSize / 2;
        var squareY = canvas.height / 2 - squareSize / 2;

        var fontSize = (squareSize * 0.05).round();
        ctx.font = fontSize.toString() + 'px VT323';

        ctx.fillStyle = '#eee';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        var openingDrift = this.stage == 0 ? this.countdown : 0;

        var playerLeft = 0.1 * squareSize + (openingDrift / 1500 * MOVEMENT_INCREMENT).roundToDouble() / MOVEMENT_INCREMENT * squareSize;
        var opponentLeft = 0.7 * squareSize - (openingDrift / 1500 * MOVEMENT_INCREMENT).roundToDouble() / MOVEMENT_INCREMENT * squareSize;

        this.upsGuy.draw((img) {
            ctx.drawImageScaledFromSource(
                img,
                0, 0, img.width, img.height,
                opponentLeft + squareX, squareY + 0.05 * squareSize,
                squareSize * 0.25, squareSize * 0.25
            );
        });

        this.player.draw((img) {
            ctx.drawImageScaledFromSource(
                img,
                0, 0, 16, 16,
                playerLeft + squareX, squareY + squareSize - squareSize * 0.5,
                squareSize * 0.45, squareSize * 0.45
            );
        });

        // Draw the opponent stats
        ctx.fillStyle = '#111';
        ctx.fillRect(
            squareX + squareSize * 0.05,
            squareY + squareSize * 0.05,
            squareSize * 0.4,
            squareSize * 0.1
        );
        ctx.fillStyle = '#eee';
        ctx.fillRect(
            squareX + squareSize * 0.05 + 4,
            squareY + squareSize * 0.05,
            squareSize * 0.4 - 4,
            squareSize * 0.1 - 4
        );
        ctx.fillStyle = '#111';
        ctx.fillText(
            'DELIVERY GUY',
            squareX + squareSize * 0.075,
            squareY + squareSize * 0.05 + fontSize
        );

        ctx.fillRect(
            squareX + squareSize * 0.075,
            squareY + squareSize * 0.065 + fontSize,
            this.opponentHP * squareSize / 100 * 0.35,
            5
        );

        // Draw the player stats
        ctx.fillStyle = '#111';
        ctx.fillRect(
            squareX + squareSize * 0.55,
            squareY + squareSize * 0.6,
            squareSize * 0.4,
            squareSize * 0.1
        );
        ctx.fillStyle = '#eee';
        ctx.fillRect(
            squareX + squareSize * 0.55 + 4,
            squareY + squareSize * 0.6,
            squareSize * 0.4 - 4,
            squareSize * 0.1 - 4
        );
        ctx.fillStyle = '#111';
        ctx.fillText(
            'HUBBLE TLSCP',
            squareX + squareSize * 0.575,
            squareY + squareSize * 0.6 + fontSize
        );

        ctx.fillRect(
            squareX + squareSize * 0.575,
            squareY + squareSize * 0.615 + fontSize,
            squareSize * 0.35,
            5
        );

        // Draw the player UI
        ctx.fillStyle = '#111';
        ctx.fillRect(
            squareX + squareSize * 0.05,
            squareY + squareSize * 0.75,
            squareSize * 0.9,
            squareSize * 0.2
        );
        ctx.fillStyle = '#eee';
        ctx.fillRect(
            squareX + squareSize * 0.05 + 4,
            squareY + squareSize * 0.75 + 4,
            squareSize * 0.9 - 8,
            squareSize * 0.2 - 8
        );
        ctx.fillStyle = '#111';
        ctx.fillText(
            this.message1,
            squareX + squareSize * 0.075,
            squareY + squareSize * 0.8
        );
        ctx.fillText(
            this.message2,
            squareX + squareSize * 0.075,
            squareY + squareSize * 0.8 + fontSize + 3
        );


        // Draw black borders
        ctx.fillStyle = '#111';
        if (squareX > 0) {
            ctx.fillRect(0, 0, squareX, canvas.height);
            ctx.fillRect(squareX + squareSize, 0, canvas.width - squareX - squareSize, canvas.height);
        }
        if (squareY > 0) {
            ctx.fillRect(0, 0, canvas.width, squareY);
            ctx.fillRect(0, squareY + squareSize, canvas.width, canvas.height - squareY - squareSize);
        }
    }

    bool tickCountDown(delta) {
        if (this.countdown == 0) {
            return true;
        }
        this.countdown -= delta;
        if (this.countdown <= 0) {
            this.countdown = 0;
            return true;
        }
        return false;
    }

    void setStage(int stage) {
        this.stage = stage;
        switch (stage) {
            case 1:
                this.countdown = 2000;
                sound.play('bad_choice');
                this.message1 = 'DELIVERY GUY uses ' + INSULTING_MOVES[rng.nextInt(INSULTING_MOVES.length)];
                this.message2 = '';
                break;
            case 2:
                this.countdown = 2000;
                sound.play('hubble_wife');
                this.message1 = 'HUBBLE WIFE is very pleased!';
                this.message2 = '';
                break;
            case 3:
                this.countdown = 2000;
                sound.play('rage');
                this.message1 = 'YOU are ENRAGED!';
                this.message2 = '';
                break;
            case 4:
                this.selectedMove = 0;
                this.battleMenu();
                break;
            case 5:
                this.countdown = 2000;
                sound.play('select');
                this.message1 = 'It is super effective!';
                this.message2 = '';
                break;
            case 6:
                this.countdown = 2000;
                this.message1 = 'It has no effect';
                this.message2 = 'because you are a telescope';
                break;
            case 7:
                this.countdown = 2000;
                this.message1 = 'DELIVERY GUY has passed out!';
                this.message2 = '';
                break;
        }
    }

    void battleMenu() {
        var line1 = '';
        var line2 = '';

        line1 += (this.selectedMove == 0 ? CARET : ANTICARET) + MOVES[0];
        line2 += (this.selectedMove == 1 ? CARET : ANTICARET) + MOVES[1];

        line1 = line1.padRight(8);
        line2 = line2.padRight(8);

        line1 += (this.selectedMove == 2 ? CARET : ANTICARET) + MOVES[2];
        line2 += (this.selectedMove == 3 ? CARET : ANTICARET) + MOVES[3];

        this.message1 = line1;
        this.message2 = line2;

    }

    void handleKey(e) {
        switch (this.stage) {
            case 0:
            case 1:
            case 7:
                if (e.keyCode == 13) {
                    this.setStage(this.stage + 1);
                    return;
                }
                break;
            case 2:
                if (e.keyCode == 13) {
                    this.setStage(4);
                    return;
                }
        }
        if (this.stage != 4) return;


        // Handle attacks
        if (e.keyCode == 13) {
            switch (this.selectedMove) {
                case 1:
                    sound.play('select');
                    this.setStage(5);
                    break;
                case 0:
                case 2:
                case 3:
                    sound.play('bad_choice');
                    this.setStage(6);
            }
            return;
        }

        if (e.keyCode == 40) { // Down
            this.selectedMove += 1;
        } else if (e.keyCode == 38) { // Up
            this.selectedMove -= 1;
        } else if (e.keyCode == 37) { // Left
            this.selectedMove -= 2;
        } else if (e.keyCode == 39) { // Right
            this.selectedMove += 2;
        } else {
            return;
        }

        if (this.selectedMove < 0) {
            this.selectedMove += 4;
        } else if (this.selectedMove > 3) {
            this.selectedMove -= 4;
        }
        this.battleMenu();
        sound.play('menu_down');
    }

    void tick(int delta) {

        switch (this.stage) {
            case 0:
            case 1:
                if (this.tickCountDown(delta)) {
                    this.setStage(this.stage + 1);
                }
                break;
            case 2:
                if (this.tickCountDown(delta)) {
                    this.setStage(4);
                }
                break;
            case 3:
            case 4:
                break;

            case 5:
                if (this.opponentHP > 0) {
                    this.opponentHP -= (delta * 0.05).round();
                    if (this.opponentHP <= 0) {
                        this.opponentHP = 0;
                        this.setStage(7);
                    }
                }
                break;
            case 6:
                if (this.tickCountDown(delta)) {
                    this.setStage(1);
                }
                break;
            case 7:
                break;
        }


    }

}
