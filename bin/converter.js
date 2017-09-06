#! /usr/bin/env node

const commandLineArgs = require('command-line-args');
const commandLineUsage = require('command-line-usage');
const consoleStamp = require('console-stamp');
const main = require('..');

const optionDefinitions = [
	{
		name: 'type',
		alias: 't',
		description: 'input database type (mongo/redis/postgres)'
	},
	{
		name: 'input',
		alias: 'i',
		description: 'input database connection URL'
	},
	{
		name: 'output',
		alias: 'o',
		description: 'output database connection URL (PostgreSQL)'
	},
	{
		name: 'concurrency',
		alias: 'j',
		type: Number,
		description: 'number of queries executed at a time (default: 10)',
		defaultValue: 10
	}
];

const usage = [
	{
		header: 'Parameters',
		optionList: optionDefinitions
	}
];

var options;
try {
	options = commandLineArgs(optionDefinitions);
} catch (ex) {
	if (ex.message !== 'Unknown option: --help') {
		console.error(ex.message);
	}
}

if (!options || !options.type || !options.input || !options.output || options.concurrency < 1) {
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
