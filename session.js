const transaction = require('./transaction.js');
const copyFrom = require('pg-copy-streams').from;

async function copySessions(pool, input, connection) {
	await transaction('Copy sessions', pool, async function(tx) {
		var stream = tx.query(copyFrom(`COPY "session" FROM STDIN`));

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
			var row = transformRow([data.sid, data.sess, data.expire]);
			await write(row);
		});

		stream.end();

		await promise;
	});
}

function transformRow(columns) {
	return columns.map(function(col) {
		if (col === null) {
			return '\\N';
		}

		return String(col).replace(/[\\\n\r\t]/g, function(x) {
			switch (x) {
				case '\\':
					return '\\\\';
				case '\n':
					return '\\n';
				case '\r':
					return '\\r';
				case '\t':
					return '\\t';
			}
		});
	}).join('\t') + '\n';
}

module.exports = copySessions;
