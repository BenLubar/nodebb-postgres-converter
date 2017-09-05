const commandLineArgs = require('command-line-args');
const commandLineUsage = require('command-line-usage');
const { Pool } = require('pg');
const copyDatabase = require('./copy.js');
const executeSQL = require('./sql.js');

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
	}
];

const usage = [
	{
		header: 'Required Parameters',
		optionList: optionDefinitions
	}
];

async function main() {
	var options;
	try {
		options = commandLineArgs(optionDefinitions);
	} catch (ex) {
		if (ex.message !== 'Unknown option: --help') {
			console.error(ex.message);
		}
	}

	if (!options || !options.type || !options.input || !options.output) {
		console.log(commandLineUsage(usage));
		process.exit(1);
		return;
	}

	if (!/^[a-z]+$/.test(options.type)) {
		throw new Exception('Invalid input database type.');
	}

	var input;
	try {
		input = require('./reader/' + options.type + '.js');
	} catch (ex) {
		throw new Exception('Invalid input database type.');
	}

	const pool = new Pool({
		connectionString: options.output
	});

	await executeSQL(pool, '0.init');
	await copyDatabase(pool, input, options.input);
	await executeSQL(pool, '1.legacy');
	await executeSQL(pool, '2.convert');
	await Promise.all([async function() {
		await executeSQL(pool, '3.cleanup/delete_legacy/1.objects');
		await executeSQL(pool, '3.cleanup/delete_legacy/2.sets');
		await executeSQL(pool, '3.cleanup/delete_legacy/3.counters');
	}(), executeSQL(pool, '3.cleanup/foreign_keys')]);

	await pool.end();
}

module.exports = main;
