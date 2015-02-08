library entities.generic;

import 'dart:html';
import 'dart:math' as Math;

import 'entities.dart' as entities;
import 'level.generic.dart';
import 'settings.dart' as settings;
import 'tiles.dart' as tiles;


const DELTA_RATIO = 1000 / 60; // 60FPS

const GRAVITY = 0.0475;
const MAX_SPEED = 0.975;


abstract class Entity {

    double x;
    double y;
    double velX = 0.0;
    double velY = 0.0;

    String type();

    Entity() {
        this.reset();
    }

    void reset();

    void draw(CanvasRenderingContext2D ctx, Level level, int offsetX, int offsetY);

    bool tick(int delta, Level level);
}
