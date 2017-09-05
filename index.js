const commandLineArgs = require('command-line-args');
const commandLineUsage = require('command-line-usage');
const path = require('path');
const bluebird = require('bluebird');
const readDir = bluebird.promisify(require('fs').readdir);
const readFile = bluebird.promisify(require('fs').readFile);
const { Pool } = require('pg');

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

exports.main = async function() {
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
};

async function findSQLFiles(category) {
	var dir = path.join(__dirname, 'sql', category);
	var files = await readDir(dir);
	return files.filter(function(name) {
		return name.endsWith('.sql');
	}).map(function(name) {
		return path.join(dir, name);
	});
}

async function executeSQL(pool, category) {
	var label = 'Step: ' + category;
	console.time(label);

	var filePaths = await findSQLFiles(category);
	await Promise.all(filePaths.map(async function(filePath) {
		var sql = await readFile(filePath, 'utf8');
		await transaction('SQL: ' + category + '/' + path.basename(filePath), pool, async function(tx) {
			await tx.query(sql);
		});
	}));

	console.timeEnd(label);
}

async function transaction(label, pool, callback) {
	console.time(label);
	const client = await pool.connect();

	try {
		await client.query('START TRANSACTION;');
		await callback(client);
		await client.query('COMMIT;');
	} catch (ex) {
		await client.query('ROLLBACK;');
		console.error('Transaction failed: ' + label);
		throw ex;
	} finally {
		client.release();
		console.timeEnd(label);
	}
}

// TODO: convert this to COPY FROM
async function copyDatabase(pool, input, connection) {
	var total = 0;
	var copied = 0;
	var skipped = 0;
	await transaction('Copy legacy_objects', pool, async function(tx) {
		await input(connection, async function(count) { total = count; }, async function(data) {
			var values = transformData(data);
			if (values) {
				await tx.query({
					text: 'INSERT INTO "objects_legacy" ("key0", "key1", "value", "score", "data") VALUES ($1, $2, $3, $4, $5);',
					values: values
				});
				copied++;
			} else {
				skipped++;
			}
			if ((copied + skipped) % 10000 === 0) {
				console.log(('  ' + Math.floor(100 * (copied + skipped) / total)).substr(-3) + '% - ' + copied + ' objects copied (' + skipped + ' skipped)');
			}
		});

		if ((copied + skipped) % 10000 !== 0) {
			console.log('100% - ' + copied + ' objects copied (' + skipped + ' skipped)');
		}

		if (copied + skipped !== total) {
			console.warn('There were ' + (copied + skipped) + ' objects, but ' + total + ' were expected.');
		}
	});
}

function transformData(obj) {
	delete obj._id;
	if (!obj.hasOwnProperty('_key')) {
		return null;
	}

	var key = String(obj._key).replace(/\x00/g, 'x00');
	delete obj._key;

	var value = null;
	if (obj.hasOwnProperty('value')) {
		value = transformValue(obj.value);
	}
	delete obj.value;

	var score = null;
	if (obj.hasOwnProperty('score')) {
		score = transformValue(obj.score);
	}
	delete obj.score;

	// clean up importer bugs
	delete obj.undefined;
	if (key.startsWith('chat:room:') && key.endsWith('uids') && !key.endsWith(':uids')) {
		return null;
	}

	var data = transformValue(obj);

	var keySplit = key.split(':');
	return [keySplit[0], keySplit.slice(1), value, score, data];
}

function transformValue(v) {
	if (v instanceof Date) {
		return v.getTime();
	}
	if (typeof v === 'number' && Number.isNaN(v)) {
		return 'NaN';
	}
	if (typeof v === 'string') {
		return v.replace(/\x00/g, 'x00');
	}
	if (v === null) {
		return null;
	}

	if (typeof v === 'object') {
		for (var k of Object.keys(v)) {
			v[k] = transformValue(v[k]);
		}
	}

	return v;
}
