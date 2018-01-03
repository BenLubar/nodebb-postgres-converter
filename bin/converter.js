#! /usr/bin/env node

const commandLineArgs = require('command-line-args');
const commandLineUsage = require('command-line-usage');
const consoleStamp = require('console-stamp');
const main = require('..');

const optionDefinitions = [
	{
		name: 'type',
		alias: 't',
		description: 'input database type (mongo/redis/postgres)',
		group: 'required'
	},
	{
		name: 'input',
		alias: 'i',
		description: 'input database connection URL',
		group: 'required'
	},
	{
		name: 'output',
		alias: 'o',
		description: 'output database connection URL (PostgreSQL)',
		group: 'required'
	},
	{
		name: 'concurrency',
		alias: 'j',
		type: Number,
		description: 'number of queries executed at a time (default: 10)',
		defaultValue: 10,
		group: 'optional'
	}
];

const usage = [
	{
		header: 'Required Parameters',
		optionList: optionDefinitions,
		group: ['required']
	},
	{
		header: 'Additional Parameters',
		optionList: optionDefinitions,
		group: ['optional']
	}
];

var options;
try {
	options = commandLineArgs(optionDefinitions)._all;
} catch (ex) {
	if (ex.message !== 'Unknown option: --help') {
		console.error(ex.message);
		process.exit(1);
		return;
	}
}

if (!options || !options.type || !options.input || !options.output || options.concurrency < 1 || options.concurrency !== Math.floor(options.concurrency)) {
	console.log(options);
	console.log(commandLineUsage(usage));
	process.exit(1);
	return;
}

if (!/^[a-z]+$/.test(options.type)) {
	console.error('Invalid input database type.');
	process.exit(1);
	return;
}

var reader;
try {
	reader = require('../reader/' + options.type + '.js');
} catch (ex) {
	console.error('Invalid input database type.');
	process.exit(1);
	return;
}

consoleStamp(console, {pattern: 'yyyy-mm-dd HH:MM:ss.l'});

main(reader, options.input, options.output, options.concurrency).catch(function(ex) {
	console.error(ex.stack);
	process.exit(2);
});
