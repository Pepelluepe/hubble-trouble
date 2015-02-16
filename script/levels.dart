library levels;

import 'audio.dart' as audio;
import 'level.fps.dart';
import 'level.generic.dart';
import 'level.manbattle.dart';
import 'level.menu.dart';
import 'level.message.dart';
import 'level.photo.dart';
import 'level.slidePuzzle.dart';
import 'level.title.dart';
import 'slidingleveldata.dart';
import 'threedeeleveldata.dart';


List<Level> levels = [];
var DISABILITY_LEVEL = -1;
var CURRENT_LEVEL = 0;

Map passMap = {};

void addLevel(String passWord, Level level) {
    levels.add(level);
    if (passWord != null) {
        passMap[passWord] = levels.length - 1;
    }
}

int passwordTest(String passWord) {
    return passMap.containsKey(passWord) ? passMap[passWord] : -1;
}


void init() {

    var ctx = new Context(passwordTest, next, goTo);

    addLevel(null, new LevelTitle(ctx, 750, soundName: 'bastacorp'));
    addLevel(null, new LevelMenu(ctx));

    var i = 0;
    SLIDING_LEVELS.forEach((level) {
        var password = level.containsKey('password') ? level['password'] : null;

        if (level.containsKey('message')) {
            addLevel(password, new LevelMessage(ctx, 2000, level['message']));
            password = null;
        }

        addLevel(password, new LevelSlidePuzzle(ctx, i % 4, level['width'], level['height'], level['content']));
        addLevel(null, new LevelMessage(ctx, 2000, 'Photo Op!'));
        addLevel(null, new LevelPhoto(ctx, level['photo']));
        if (i + 1 != SLIDING_LEVELS.length && SLIDING_LEVELS[i + 1].containsKey('password')) {
            addLevel(null, new LevelMessage(ctx, 2000, 'PASSWORD: ' + SLIDING_LEVELS[i + 1]['password']));
        }
        i += 1;
    });

    addLevel(null, new LevelMessage(ctx, 2500, 'Hubble Wife is in bed with another man!'));
    addLevel('xh1', new LevelManbattle(ctx));
    addLevel(null, new LevelMessage(ctx, 2500, 'PASSWORD: ups'));
    addLevel('ups', new LevelMessage(ctx, 2500, 'You need some fresh air'));

    THREE_DEE_LEVELS.forEach((level) {
        var password = level.containsKey('password') ? level['password'] : null;
        addLevel(password, new LevelFPS(ctx, level['content'], level['width'], level['height'], level['startX'], level['startY']));
    });


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
