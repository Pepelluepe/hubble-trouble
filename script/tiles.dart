const int TILE_EMPTY = 0;
const int TILE_DEBRIS1 = 1;
const int TILE_DEBRIS2 = 2;
const int TILE_DEBRIS3 = 3;
const int TILE_DEBRIS4 = 4;
const int TILE_DEBRIS5 = 5;

const int TILE_START = 13;
const int TILE_END = 14;

Map<int, int> IMAGES = {
    TILE_DEBRIS1: 0,
    TILE_DEBRIS2: 1,
    TILE_DEBRIS3: 2,
    TILE_DEBRIS4: 3,
    TILE_DEBRIS5: 4,

    TILE_START: 12,
    TILE_END: 13,
};

// Solid cannot be passed through.
Set<int> SOLID = new Set.from([
    TILE_DEBRIS1,
    TILE_DEBRIS2,
    TILE_DEBRIS3,
    TILE_DEBRIS4,
    TILE_DEBRIS5,
]);


bool isPassable(int tile) {
    return !SOLID.contains(tile);
}
