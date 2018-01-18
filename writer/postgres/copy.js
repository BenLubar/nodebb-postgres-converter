'use strict';

const copyFrom = require('pg-copy-streams').from;
const transformRow = require('./transform.js').row;

async function copyData(db, each) {
	var stream = db.query(copyFrom(`COPY "objects" FROM STDIN`));

	var promise = new Promise(function(resolve, reject) {
		stream.on('error', reject);
		stream.on('end', resolve);
	});

	function write(data) {
		var values = transformRow([JSON.stringify(data)]);

		return new Promise(function(resolve, reject) {
			var ok = stream.write(values, 'utf8');
			if (ok) {
				return resolve();
			}
			stream.once('drain', resolve);
		});
	}

	await each(write);

	stream.end();

	await promise;
}

module.exports = copyData;
