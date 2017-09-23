const Elm = require('./elm.js');

const app = Elm.Main.worker();

app.ports.emit.subscribe(function(v) {
    switch (v.type) {
        case 'start':
            process.stderr.write(v.data + '\n');
            process.stderr.write('\x1B[?25l');
            break;

        case 'running':
            process.stderr.write(v.data);
            break;

        case 'done':
            process.stderr.write(v.msg);
            process.stderr.write('\x1B[?25h\n\n');
            console.log(JSON.stringify(v.data, null, 2));
            process.exit(0);
    }
});

