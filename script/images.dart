library images;

import 'dart:async';
import 'dart:html';


Future<ImageElement> loadImage(String src) {
    var comp = new Completer();

    var img = new ImageElement();
    img.src = src;
    img.onLoad.listen((e) {
        comp.complete(img);
    });

    return comp.future;
}

Map images = {
    'bastacorp': loadImage('img/bastacorp.jpg'),
    'menu': loadImage('img/menu.png'),
    'menu_hubble': loadImage('img/menu_hubble.png'),
    'tiles': loadImage('img/tiles.png'),
    'player': loadImage('img/player.png'),
    'space': loadImage('img/space.jpg'),
    'trinkets': loadImage('img/trinkets.png'),
};

Future<List> waitFor(Iterable<String> names) {
    return Future.wait(names.map((name) => images[name]));
}

var all = Future.wait(images.values);

class Drawable {

    Future<ImageElement> future;
    ImageElement fetched;

    Drawable(String name) {
        this.future = images[name];
        this.future.then((img) {
            this.fetched = img;
        });
    }

    void draw(Function drawer) {
        if (this.fetched != null) {
            drawer(this.fetched);
        }
    }

    void drawEventually(Function drawer) {
        this.future.then(drawer);
    }
}

Drawable get(String name) {
    return new Drawable(name);
}
