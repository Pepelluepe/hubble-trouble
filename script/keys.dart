library keys;

import 'dart:html';

import 'events.dart' as events;


var up = new events.EventTarget();
var down = new events.EventTarget();

var downArrow = false;
var leftArrow = false;
var rightArrow = false;
var upArrow = false;


var CHAR_CODES = {
    48: '0',
    49: '1',
    50: '2',
    51: '3',
    52: '4',
    53: '5',
    54: '6',
    55: '7',
    56: '8',
    57: '9',
    65: 'a',
    66: 'b',
    67: 'c',
    68: 'd',
    69: 'e',
    70: 'f',
    71: 'g',
    72: 'h',
    73: 'i',
    74: 'j',
    75: 'k',
    76: 'l',
    77: 'm',
    78: 'n',
    79: 'o',
    80: 'p',
    81: 'q',
    82: 'r',
    83: 's',
    84: 't',
    85: 'u',
    86: 'v',
    87: 'w',
    88: 'x',
    89: 'y',
    90: 'z',

    96 : '0',
    97 : '1',
    98 : '2',
    99 : '3',
    100 : '4',
    101 : '5',
    102 : '6',
    103 : '7',
    104 : '8',
    105 : '9',

    106: '*',
    107: '+',
    109: '-',
    110: '.',
    111: '/',
    186: ';',
    187: '=',
    188: ',',
    189: '-',
    190: '.',
    191: '/',
    192: '`',
    219: '[',
    220: '\\',
    221: ']',
    222: '\'',
};

const BACKSPACE = 8;
const ENTER = 13;


void _keypress(KeyEvent e, bool wasSet) {
    if (!e.metaKey && !e.altKey) e.preventDefault();
    if (!wasSet) {
        up.fire(e.keyCode, e);
        up.fire('any', e);
    }
    switch(e.keyCode) {
        case 37: // Left
        case 65: // A
            leftArrow = wasSet;
            break;
        case 38: // Up
        case 87: // W
            upArrow = wasSet;
            break;
        case 39: // Right
        case 68: // D
            rightArrow = wasSet;
            break;
        case 40: // Down
        case 83: // S
            downArrow = wasSet;
            break;
    }
    if (wasSet) {
        down.fire(e.keyCode, e);
        down.fire('any', e);
    }
}

void init() {
    document.body.onKeyDown.listen((e) {
        _keypress(e, true);
    });
    document.body.onKeyUp.listen((e) {
        _keypress(e, false);
    });
}
