'use strict';

const cleanData = require('./clean.js').data;

async function copyDatabase(reader, input, output) {
	var total = 0;
	var copied = 0;
	var skipped = 0;

	console.time('Copy objects');

	try {
		console.log('Counting objects...');

		await input(connection, async function(count) {
			total = count;
			console.log('Attempting to copy ' + total + ' objects...');
		}, async function(data) {
			await output(async function (write) {
				var values = cleanData(data);
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
		});

		if ((copied + skipped) % 100000 !== 0) {
			console.log('100% - ' + copied + ' objects copied (' + skipped + ' skipped)');
		}

		if (copied + skipped !== total) {
			console.warn('There were ' + (copied + skipped) + ' objects, but ' + total + ' were expected.');
		}
	} finally {
		console.timeEnd('Copy objects');
	}
}

async function main(reader, input, writer, output, concurrency, memory, sessionReader, sessionInput) {
	await writer(output, concurrency, memory, async function (copyData, copySessions) {
		var data = copyDatabase(reader, input, copyData);
		var sessions = sessionInput ? copySessions(sessionReader, sessionInput) : Promise.resolve();
		await Promise.all([data, sessions]);
	});
}

module.exports = main;
