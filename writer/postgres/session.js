'use strict';

const copyFrom = require('pg-copy-streams').from;
const transformRow = require('./transform.js').row;

async function copySessions(db, input, connection) {
	console.time('Copy sessions');

	try {
		var stream = db.query(copyFrom(`COPY "session" FROM STDIN`));

		var promise = new Promise(function(resolve, reject) {
			stream.on('error', reject);
			stream.on('end', resolve);
		});

		function write(values) {
			return new Promise(function(resolve, reject) {
				var ok = stream.write(values, 'utf8');
				if (ok) {
					return resolve();
				}
				stream.once('drain', resolve);
			});
		}

		await input(connection, async function(data) {
			var row = transformRow([data.sid, data.sess, new Date(data.expire).toISOString()]);
			await write(row);
		});

		stream.end();

		await promise;
	} finally {
		console.timeEnd('Copy sessions');
	}
}

module.exports = copySessions;
