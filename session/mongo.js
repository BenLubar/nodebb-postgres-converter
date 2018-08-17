'use strict';

const { MongoClient } = require('mongodb');

module.exports = async function(connection, each) {
	const client = await MongoClient.connect(connection);
	const db = client.db();

	try {
		const sessions = db.collection('sessions');

		const cur = sessions.find().addCursorFlag('noCursorTimeout', true);

		var data;
		while ((data = await cur.next()) !== null) {
			await each({
				sid: data._id,
				sess: data.session,
				expire: data.expires.getTime()
			});
		}
	} finally {
		await client.close();
	}
};
