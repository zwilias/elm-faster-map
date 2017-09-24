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
            process.stdout.write(JSON.stringify(v.data, null, 0));
            process.stdout.write('\n');
            process.exit(0);
    }
});
