import 'audio.dart' as audio;
import 'drawing.dart' as drawing;
import 'entities.dart' as entities;
import 'images.dart' as images;
import 'keys.dart' as keys;
import 'levels.dart' as levels;
import 'mouse.dart' as mouse;
import 'sound.dart' as sound;
import 'timing.dart' as timing;


void main() {
    audio.init();
    keys.init();
    mouse.init();
    sound.init();

    drawing.init();
    entities.init();

    images.all.then((_) {
        levels.init();
        timing.start();
    });
}
