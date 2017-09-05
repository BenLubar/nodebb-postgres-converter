'use strict';

const { MongoClient } = require('mongodb');

module.exports = async function(connection, count, each) {
	const db = await MongoClient.connect(connection);

	try {
		const objects = db.collection('objects');

		await count(await objects.count());

		const cur = objects.find().addCursorFlag('noCursorTimeout', true);

		var data;
		while ((data = await cur.next()) !== null) {
			await each(data);
		}
	} finally {
		await db.close();
	}
};
