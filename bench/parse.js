#!/usr/bin/env node

var Elm = require('./display.js');
var stdin = process.stdin,
    inputChunks = '';

stdin.resume();
stdin.setEncoding('utf8');

stdin.on('data', function(chunk) {
    inputChunks += chunk;
});

stdin.on('end', function() {
    var parsedData = JSON.parse(inputChunks);
    var app = Elm.Display.worker(parsedData);
    app.ports.emit.subscribe(function(data) {
        console.log(data);
    });
});
