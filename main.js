const { Pool } = require('pg');
const copyDatabase = require('./copy.js');
const executeSQL = require('./sql.js');

async function main(reader, input, output, concurrency) {
	const pool = new Pool({
		connectionString: output,
		max: concurrency
	});

	await executeSQL(pool, '0.init');
	await copyDatabase(pool, reader, input);
	await executeSQL(pool, '1.legacy');
	await executeSQL(pool, '2.convert');
	await executeSQL(pool, '3.cleanup');

	await pool.end();
}

module.exports = main;
