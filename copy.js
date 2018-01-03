const transaction = require('./transaction.js');
const copyFrom = require('pg-copy-streams').from;

async function copyDatabase(pool, input, connection) {
	var total = 0;
	var copied = 0;
	var skipped = 0;
	await transaction('Copy objects', pool, async function(tx) {
		var stream = tx.query(copyFrom('COPY "objects" FROM STDIN'));

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

		console.log('Counting objects...');

		await input(connection, async function(count) {
			total = count;
			console.log('Attempting to copy ' + total + ' objects...');
		}, async function(data) {
			var values = transformData(data);
			if (values) {
				await write(values);
				copied++;
			} else {
				skipped++;
			}
			if ((copied + skipped) % 100000 === 0) {
				console.log(('  ' + Math.floor(100 * (copied + skipped) / total)).substr(-3) + '% - ' + copied + ' objects copied (' + skipped + ' skipped)');
			}
		});

		stream.end();

		if ((copied + skipped) % 100000 !== 0) {
			console.log('100% - ' + copied + ' objects copied (' + skipped + ' skipped)');
		}

		if (copied + skipped !== total) {
			console.warn('There were ' + (copied + skipped) + ' objects, but ' + total + ' were expected.');
		}

		await promise;
	});
}

function transformData(obj) {
	delete obj._id;
	if (!obj.hasOwnProperty('_key')) {
		return null;
	}
	var key = obj._key;

	// clean up importer bugs
	delete obj.undefined;
	if ((key.startsWith('chat:room:') && key.endsWith('uids') && !key.endsWith(':uids')) || (key.startsWith('uid:') && key.endsWith('sessionUUID:sessionId') && !key.endsWith(':sessionUUID:sessionId'))) {
		return null;
	}

	var data = transformValue(obj);

	return transformRow([JSON.stringify(data)]);
}

function transformValue(v) {
	if (v instanceof Date) {
		return v.getTime();
	}
	if (typeof v === 'number' && Number.isNaN(v)) {
		return 'NaN';
	}
	if (typeof v === 'string') {
		return v.replace(/\x00/g, 'x00');
	}
	if (v === null) {
		return null;
	}

	if (typeof v === 'object') {
		for (var k of Object.keys(v)) {
			v[k] = transformValue(v[k]);
		}
	}

	return v;
}

function transformArray(array) {
	if (array.length === 0) {
		return '{}';
	}

	return '{"' + array.map(function(v) {
		return String(v).replace(/[\\"]/g, function(x) {
			return '\\' + x;
		});
	}).join('","') + '"}';
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

module.exports = copyDatabase;
