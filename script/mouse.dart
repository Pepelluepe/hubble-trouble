library mouse;

import 'dart:async';
import 'dart:html';

import 'events.dart' as eventsLib;

var events = new eventsLib.EventTarget();


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
