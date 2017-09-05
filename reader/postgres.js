'use strict';

const { Client } = require('pg');
const QueryStream = require('pg-query-stream');

module.exports = async function(connection, count, each) {
	const client = new Client({
		connectionString: connection
	});
	await client.connect();

	try {
		var res = await client.query('SELECT COUNT(*) c FROM "objects";');
		await count(res.rows[0].c);

		const stream = client.query(new QueryStream('SELECT "data" FROM "objects";'));

		try {
			while ((data = await stream.next()) !== null) {
				await each(data.data);
			}
		} finally {
			stream.close();
		}
	} finally {
		await client.end();
	}
};
