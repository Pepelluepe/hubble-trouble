library keys;

import 'dart:async';
import 'dart:html';

import 'events.dart';

var events = new EventTarget();


void init() {
    document.body.onMouseDown.listen((e) {
        events.fire('down', e);
    });
    document.body.onMouseUp.listen((e) {
        events.fire('up', e);
    });
    document.body.onMouseMove.listen((e) {
        events.fire('move', e);
    });
}
