'use strict';

const { Client } = require('pg');
const Cursor = require('pg-cursor');
const { promisify } = require('util');

module.exports = async function(connection, each) {
	const client = new Client({
		connectionString: connection
	});
	await client.connect();

	try {
		const stream = client.query(new Cursor(`SELECT "sid", "sess"::TEXT "sess", EXTRACT(EPOCH FROM "expire") * 1000 "expire" FROM "session"`));

		cursor.readAsync = promisify(cursor.read);

		var queue = await cursor.readAsync(1000);
		while (queue.length) {
			var next = cursor.readAsync(1000);
			for (var row of queue) {
				await each(row);
			}
			queue = await next;
		}
	} finally {
		await client.end();
	}
};
