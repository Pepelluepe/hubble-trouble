library levels;

import 'audio.dart' as audio;
import 'level.generic.dart';
import 'level.menu.dart';
import 'level.title.dart';
// import 'leveldata.dart';


List<Level> levels = [];
var DISABILITY_LEVEL = -1;
var CURRENT_LEVEL = 0;


void init() {
    levels.add(new LevelTitle(750, soundName: 'bastacorp'));
    levels.add(new LevelMenu());

    // LEVELS.forEach((level) {
    //     levels.add(new LevelPlatform(level['width'], level['height'], level['content'], level['entities']));
    //     levels.add(new LevelMelonomics());
    // });

    // levels.add(new LevelDisability());

    // DISABILITY_LEVEL = levels.length - 1;

    levels[0].reset();
}

void goTo(int level) {
    CURRENT_LEVEL = level;
    audio.stop();
    levels[CURRENT_LEVEL].reset();
}

Level getCurrent() {
    return levels[CURRENT_LEVEL];
}

void next() {
    CURRENT_LEVEL += 1;
    if (CURRENT_LEVEL == levels.length) {
        CURRENT_LEVEL = 0;
    }
    goTo(CURRENT_LEVEL);
}
