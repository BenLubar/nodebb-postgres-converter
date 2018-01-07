'use strict';

const { Client } = require('pg');
const QueryStream = require('pg-query-stream');
const { Transform } = require('stream');

module.exports = async function(connection, each) {
	const client = new Client({
		connectionString: connection
	});
	await client.connect();

	try {
		const stream = client.query(new QueryStream(`SELECT "sid", "sess"::TEXT "sess", EXTRACT(EPOCH FROM "expire") * 1000 "expire" FROM "session"`));
		const reader = new Transform({
			transform(chunk, encoding, callback) {
				each(chunk).then(callback);
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
