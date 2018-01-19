#! /usr/bin/env node

'use strict';

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
		name: 'sessionType',
		alias: 'T',
		description: 'database containing sessions (mongo/redis/postgres)',
		group: 'optional'
	},
	{
		name: 'sessionInput',
		alias: 'I',
		description: 'database connection URL for the database containing sessions',
		group: 'optional'
	},
	{
		name: 'outputType',
		alias: 'O',
		description: 'output database type (mongo/redis/postgres) (default: postgres)',
		defaultValue: 'postgres',
		group: 'optional'
	},
	{
		name: 'output',
		alias: 'o',
		description: 'output database connection URL',
		group: 'required'
	},
	{
		name: 'concurrency',
		alias: 'j',
		type: Number,
		description: 'number of queries executed at a time (default: 10)',
		defaultValue: 10,
		group: 'optional'
	},
	{
		name: 'memory',
		alias: 'm',
		description: 'amount of memory PostgreSQL should use for maintenance tasks',
		defaultValue: '64MB',
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

if (!options || (options.type && !options.input) || (!options.type && options.input) || !options.output || options.concurrency < 1 || options.concurrency !== Math.floor(options.concurrency) || (options.sessionType && !options.sessionInput) || (!options.sessionType && options.sessionInput) || (!options.type && !options.sessionType)) {
	console.log(commandLineUsage(usage));
	process.exit(1);
	return;
}

if (options.type && !/^[a-z]+$/.test(options.type)) {
	console.error('Invalid input database type.');
	process.exit(1);
	return;
}

if (options.sessionType && !/^[a-z]+$/.test(options.sessionType)) {
	console.error('Invalid session database type.');
	process.exit(1);
	return;
}

if (!/^[a-z]+$/.test(options.outputType)) {
	console.error('Invalid output database type.');
	process.exit(1);
	return;
}

var reader;
try {
	reader = options.type ? require('../reader/' + options.type + '.js') : null;
} catch (ex) {
	console.error('Invalid input database type.');
	process.exit(1);
	return;
}

var sessionReader;
try {
	sessionReader = options.sessionType require('../session/' + options.sessionType + '.js') : null;
} catch (ex) {
	console.error('Invalid session database type.');
	process.exit(1);
	return;
}

var writer;
try {
	writer = require('../writer/' + options.outputType + '.js');
} catch (ex) {
	console.error('Invalid output database type.');
	process.exit(1);
	return;
}

consoleStamp(console, {pattern: 'yyyy-mm-dd HH:MM:ss.l'});

main(reader, options.input, writer, options.output, options.concurrency, options.memory, sessionReader, options.sessionInput).catch(function(ex) {
	console.error(ex.stack);
	process.exit(2);
});
