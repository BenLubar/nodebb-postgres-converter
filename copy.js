const transaction = require('./transaction.js');
const copyFrom = require('pg-copy-streams').from;

async function copyDatabase(pool, input, connection) {
	var total = 0;
	var copied = 0;
	var skipped = 0;
	await transaction('Copy objects_legacy', pool, async function(tx) {
		var stream = tx.query(copyFrom('COPY "objects_legacy" FROM STDIN'));

		var promise = new Promise(function(resolve, reject) {
			stream.on('error', reject);
			stream.on('end', resolve);
		});

		await input(connection, async function(count) { total = count; }, async function(data) {
			var values = transformData(data);
			if (values) {
				stream.write(values, 'utf8');
				copied++;
			} else {
				skipped++;
			}
			if ((copied + skipped) % 10000 === 0) {
				console.log(('  ' + Math.floor(100 * (copied + skipped) / total)).substr(-3) + '% - ' + copied + ' objects copied (' + skipped + ' skipped)');
			}
		});

		stream.end();

		if ((copied + skipped) % 10000 !== 0) {
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

	var key = String(obj._key).replace(/\x00/g, 'x00');
	delete obj._key;

	var value = null;
	if (obj.hasOwnProperty('value')) {
		value = transformValue(obj.value);
	}
	delete obj.value;

	var score = null;
	if (obj.hasOwnProperty('score')) {
		score = transformValue(obj.score);
	}
	delete obj.score;

	// clean up importer bugs
	delete obj.undefined;
	if ((key.startsWith('chat:room:') && key.endsWith('uids') && !key.endsWith(':uids')) || (key.startsWith('uid:') && key.endsWith('sessionUUID:sessionId') && !key.endsWith(':sessionUUID:sessionId'))) {
		return null;
	}

	var data = transformValue(obj);

	var keySplit = key.split(':');
	return transformRow([keySplit[0], transformArray(keySplit.slice(1)), value, score, JSON.stringify(data)]);
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
