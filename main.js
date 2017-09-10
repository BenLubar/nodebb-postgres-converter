const { Pool } = require('pg');
const copyDatabase = require('./copy.js');
const executeSQL = require('./sql.js');

async function main(reader, input, output, concurrency) {
	const pool = new Pool({
		connectionString: output,
		max: concurrency,
		application_name: 'nodebb-postgres-converter'
	});

	pool.on('connect', function(client) {
		client.on('notice', function(notice) {
			console.log('[DB] ' + notice.message + (notice.detail ? '\n' + notice.detail : ''));
		});
	});

	console.time('Conversion');

	await executeSQL(pool, '0.init');

	await copyDatabase(pool, reader, input);

	await executeSQL(pool, '1.legacy');

	console.time('Cluster');
	await pool.query('CLUSTER VERBOSE;');
	console.timeEnd('Cluster');

	console.time('Analyze');
	await pool.query('ANALYZE VERBOSE;');
	console.timeEnd('Analyze');

	await executeSQL(pool, '2.convert');

	await executeSQL(pool, '3.cleanup');

	console.time('Cluster');
	await pool.query('CLUSTER VERBOSE;');
	console.timeEnd('Cluster');

	console.time('Vacuum');
	await pool.query('VACUUM FULL VERBOSE ANALYZE;');
	console.timeEnd('Vacuum');

	await executeSQL(pool, '4.finalize');

	console.timeEnd('Conversion');

	await pool.end();
}

module.exports = main;
