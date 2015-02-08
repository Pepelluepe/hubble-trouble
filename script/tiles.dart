const int TILE_EMPTY = 0;
const int TILE_DEBRIS = 1;

Map<int, int> IMAGES = {
    TILE_EMPTY: 0,
    TILE_DEBRIS: 1,
};

// Solid cannot be passed through.
Set<int> SOLID = new Set.from([
    TILE_DEBRIS,
]);

// Half solid is solid at half-height.
Set<int> HALF_SOLID = new Set.from([
]);

// Cloud can only be passed through going up.
Set<int> CLOUD = new Set.from([
]);


bool canStand(int tile) {
    return SOLID.contains(tile) || CLOUD.contains(tile);
}
