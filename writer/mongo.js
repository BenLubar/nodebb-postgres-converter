'use strict';

const { MongoClient } = require('mongodb');

async function bulkInsert(collection, each) {
	var op = null;

	await each(async function (doc) {
		if (op === null) {
			op = collection.initializeUnorderedBulkOp();
		}

		op.insert(doc);

		if (op.length >= 10000) {
			await op.execute();
			op = null;
		}
	});

	if (op !== null) {
		await op.execute();
	}
}

async function writer(output, concurrency, memory, callback) {
	const db = await MongoClient.connect(output);

	try {
		const objects = await db.collection('objects');

		await callback(async function (each) {
			await bulkInsert(objects, each);
		}, async function (reader, input) {
			const sessions = await db.collection('sessions');

			await bulkInsert(sessions, async function (insert) {
				await reader(input, async function (data) {
					await insert({
						_id: data.sid,
						session: data.sess,
						expires: new Date(data.expire),
					});
				});
			});

			await sessions.createIndex({expires: 1}, {expireAfterSeconds: 0});
		});
	} finally {
		await db.close();
	}
};

module.exports = writer;
