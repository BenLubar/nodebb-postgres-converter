#! /usr/bin/env node

const main = require('..');

require('console-stamp')(console, {pattern: 'yyyy-mm-dd HH:MM:ss.l'});

main().catch(function(ex) {
	console.error(ex.stack);
	process.exit(2);
});
