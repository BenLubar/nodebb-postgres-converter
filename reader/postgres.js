'use strict';

const { Client } = require('pg');
const QueryStream = require('pg-query-stream');
const { Transform } = require('stream');

module.exports = async function(connection, count, each) {
	const client = new Client({
		connectionString: connection
	});
	await client.connect();

	try {
		var res = await client.query('SELECT COUNT(*) c FROM "objects";');
		await count(res.rows[0].c);

		const stream = client.query(new QueryStream('SELECT "data" FROM "objects";'));
		const reader = new Transform({
			transform(chunk, encoding, callback) {
				each(chunk.data).then(callback);
			}
		});

		stream.pipe(reader);

		try {
			await new Promise(function(resolve, reject) {
				reader.on('end', resolve);
				reader.on('error', reject);
			});
		} finally {
			stream.close();
		}
	} finally {
		await client.end();
	}
};
