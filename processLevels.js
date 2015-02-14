#!/usr/bin/env node

var fs = require('fs');


function getLevelData(levelData) {
    var minLevelData = new ArrayBuffer(levelData.length);
    var ldView = new Uint8Array(minLevelData);
    for (var i = 0; i < levelData.length; i++) {
        ldView[i] = levelData[i];
    }
    return (new Buffer(String.fromCharCode.apply(null, ldView))).toString('base64');
}

function getEntityData(objectLayer) {
    if (!objectLayer) return [];
    return objectLayer.objects.map(function(obj) {
        return {
            id: obj.gid - 101,
            x: Math.round(obj.x / 8),
            y: objectLayer.height - Math.round(obj.y / 8),
        };
    });
}


fs.readdir('levels/sliding/', function(err, list) {
    if (err) process.exit(1);

    var data = [];

    list.sort().forEach(function(file) {
        var file = 'levels/sliding/' + file;

        var contents = fs.readFileSync(file);
        var parsed = JSON.parse(contents);

        var height = parsed.height;
        var width = parsed.width;

        data.push({
            height: height,
            width: width,
            content: getLevelData(parsed.layers[0].data),
            entities: getEntityData(parsed.layers[1]),
            message: parsed.properties && parsed.properties.goal,
            photo: parsed.properties && parsed.properties.photo,
            password: parsed.properties && parsed.properties.password,
        });

    });

    var template = fs.readFileSync('levels/template.sliding.dart.txt').toString();
    fs.writeFileSync('script/slidingleveldata.dart', template.replace('%s', JSON.stringify(data)));
});


fs.readdir('levels/threedee/', function(err, list) {
    if (err) process.exit(1);

    var data = [];

    list.sort().forEach(function(file) {
        var file = 'levels/threedee/' + file;

        var contents = fs.readFileSync(file);
        var parsed = JSON.parse(contents);

        var height = parsed.height;
        var width = parsed.width;

        data.push({
            height: height,
            width: width,
            content: getLevelData(parsed.layers[0].data),
            startX: parsed.properties && parsed.properties.x | 0,
            startY: parsed.properties && parsed.properties.y | 0,
            password: parsed.properties && parsed.properties.password,
        });

    });

    var template = fs.readFileSync('levels/template.threedee.dart.txt').toString();
    fs.writeFileSync('script/threedeeleveldata.dart', template.replace('%s', JSON.stringify(data)));
});
