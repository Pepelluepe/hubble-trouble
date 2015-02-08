library drawing;

import 'dart:html';

import 'entities.dart' as entities;
import 'images.dart' as images;
import 'levels.dart' as levels;
import 'settings.dart' as settings;


var _can;
var _ctx;

var _width;
var _height;

var entitiesDrawable;

const PAUSE_TEXT = 'Pause';
const SCALE = 1;


void init() {
    _can = document.querySelector('canvas');
    _ctx = _can.getContext('2d');

    _width = _can.width;
    _height = _can.height;

    onResize(null);
    window.onResize.listen(onResize);

    // entitiesDrawable = images.get('entities');

}

void onResize(Event e) {
    _can.width = _width = (document.body.clientWidth / SCALE).ceil();
    _can.height = _height = (document.body.clientHeight / SCALE).ceil();
}

void drawUI() {
    // entitiesDrawable.draw((img) {
    //     _ctx.drawImageScaledFromSource(
    //         img,
    //         0, 0,
    //         8, 8,
    //         10, _height - 8 - settings.tile_size,
    //         settings.tile_size, settings.tile_size
    //     );
    // });
}

void drawPaused() {
    var modifierWidth = _ctx.measureText(PAUSE_TEXT);

    _ctx.font = '60px VT323';
    _ctx.fillStyle = 'black';
    _ctx.fillText(PAUSE_TEXT, _width / 2 - modifierWidth.width / 2 + 4, _height / 2 - 30 + 4);
    _ctx.fillStyle = 'white';
    _ctx.fillText(PAUSE_TEXT, _width / 2 - modifierWidth.width / 2, _height / 2 - 30);
}

void draw() {
    _ctx.imageSmoothingEnabled = false;
    levels.getCurrent().draw(_ctx, drawUI);
}
