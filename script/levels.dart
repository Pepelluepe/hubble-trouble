library levels;

import 'audio.dart' as audio;
import 'level.generic.dart';
import 'level.message.dart';
import 'level.menu.dart';
import 'level.slidePuzzle.dart';
import 'level.title.dart';
import 'leveldata.dart';


List<Level> levels = [];
List<String> passwords = [
    null,
    null,
    null,
    'phot',
];
var DISABILITY_LEVEL = -1;
var CURRENT_LEVEL = 0;

Map passMap = {};

void addLevel(String passWord, Level level) {
    levels.add(level);
    if (passWord != null) {
        passMap[passWord] = level;
    }
}

bool passwordTest(String passWord) {
    return passMap.containsKey(passWord);
}


void init() {

    var ctx = new Context(passwordTest, next);

    addLevel(null, new LevelTitle(ctx, 750, soundName: 'bastacorp'));
    addLevel(null, new LevelMenu(ctx));

    var i = 0;
    LEVELS.forEach((level) {
        if (level['message']) addLevel(passwords[i], new LevelMessage(ctx, 1250, level['message']));
        addLevel(!level['message'] ? passwords[i] : null, new LevelSlidePuzzle(ctx, i % 4, level['width'], level['height'], level['content']));
        i += 1;
    });

    // levels.add(new LevelDisability());

    // DISABILITY_LEVEL = levels.length - 1;

    levels[0].reset();
}

void goTo(int level) {
    getCurrent().cleanUp();
    CURRENT_LEVEL = level;
    audio.stop();
    levels[CURRENT_LEVEL].reset();
}

Level getCurrent() {
    return levels[CURRENT_LEVEL];
}

void next() {
    var nextLevel = CURRENT_LEVEL + 1;
    if (nextLevel == levels.length) {
        nextLevel = 0;
    }
    goTo(nextLevel);
    CURRENT_LEVEL = nextLevel;
}
