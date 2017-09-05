#! /usr/bin/env node

const converter = require('..');

require('console-stamp')(console, {pattern: 'yyyy-mm-dd HH:MM:ss.l'});

converter.main().catch(function(ex) {
	console.error(ex.stack);
	process.exit(2);
});
