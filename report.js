const path = require('path');
const { promisify } = require('util');
const fs = require('fs');
const readFile = promisify(fs.readFile);
const QueryStream = require('pg-query-stream');
const transaction = require('./transaction.js');

module.exports = async function makeReport(pool) {
	var sql = await readFile(path.join(__dirname, 'sql', '5.report.sql'), 'utf8');
	await transaction('Generate report', pool, function(tx) {
		const file = fs.createWriteStream('conversion-report.log');
		const stream = tx.query(new QueryStream(sql));

		return new Promise(function(resolve) {
			stream.on('data', function(data) {
				file.write('[' + data.type + '] ' + data.key, 'utf8');
				if (data.members !== null) {
					file.write(' (members: ' + data.members + ')', 'utf8');
				}
				file.write('\n');
			});

			stream.on('end', function() {
				stream.close();
				file.end(resolve);
			});
		});
	});
};
